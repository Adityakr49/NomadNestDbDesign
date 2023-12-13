-- 1) Trigger to update the total price of a booking when the check-in date is modified:
CREATE OR REPLACE FUNCTION update_booking_total_price()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE booking
    SET price = (NEW.checkout - NEW.checkin) * (SELECT price FROM room WHERE rid = NEW.rid)
    WHERE bid = NEW.bid;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_booking_update
AFTER UPDATE OF checkin ON booking
FOR EACH ROW
EXECUTE FUNCTION update_booking_total_price();



-- 2) Trigger function for review insertion:
CREATE OR REPLACE FUNCTION update_review_statistics_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Update total_reviews in "user" table
    UPDATE "user"
    SET total_reviews = total_reviews + 1
    WHERE uid = (SELECT uid FROM booking WHERE bid = NEW.bid);

    -- Update avgrating in "hotel" table
    UPDATE hotel
    SET avgrating = (
        SELECT AVG(rating)
        FROM review
        WHERE bid IN (SELECT bid FROM booking WHERE pid = (SELECT pid FROM booking WHERE bid = NEW.bid))
    )
    WHERE pid = (SELECT pid FROM booking WHERE bid = NEW.bid);

    -- Update avgrating in "room" table
    UPDATE room
    SET avgrating = (
        SELECT AVG(rating)
        FROM review
        WHERE bid IN (SELECT bid FROM booking WHERE rid = (SELECT rid FROM booking WHERE bid = NEW.bid))
    )
    WHERE rid = (SELECT rid FROM booking WHERE bid = NEW.bid);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER after_review_insert
AFTER INSERT ON review
FOR EACH ROW
EXECUTE FUNCTION update_review_statistics_insert();




-- 3) Trigger function for review deletion:
CREATE OR REPLACE FUNCTION update_review_statistics_delete()
RETURNS TRIGGER AS $$
BEGIN
    -- Update total_reviews in "user" table
    UPDATE "user"
    SET total_reviews = total_reviews - 1
    WHERE uid = (SELECT uid FROM booking WHERE bid = OLD.bid);

    -- Update avgrating in "hotel" table
    UPDATE hotel
    SET avgrating = (
        SELECT AVG(rating)
        FROM review
        WHERE bid IN (SELECT bid FROM booking WHERE pid = (SELECT pid FROM booking WHERE bid = OLD.bid))
    )
    WHERE pid = (SELECT pid FROM booking WHERE bid = OLD.bid);

    -- Update avgrating in "room" table
    UPDATE room
    SET avgrating = (
        SELECT AVG(rating)
        FROM review
        WHERE bid IN (SELECT bid FROM booking WHERE rid = (SELECT rid FROM booking WHERE bid = OLD.bid))
    )
    WHERE rid = (SELECT rid FROM booking WHERE bid = OLD.bid);

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger to execute the function after deleting a review
CREATE TRIGGER after_review_delete
AFTER DELETE ON review
FOR EACH ROW
EXECUTE FUNCTION update_review_statistics_delete();


-- 4)Trigger function for enforcing maximum concurrent bookings per user
CREATE OR REPLACE FUNCTION enforce_max_concurrent_bookings()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM booking WHERE uid = NEW.uid AND checkin <= NEW.checkout AND checkout >= NEW.checkin) >= 3 THEN
        RAISE EXCEPTION 'User cannot have more than 3 concurrent bookings.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to execute the function before inserting a new booking
CREATE TRIGGER before_booking_insert
BEFORE INSERT ON booking
FOR EACH ROW
EXECUTE FUNCTION enforce_max_concurrent_bookings();-- 4)Trigger function for enforcing maximum concurrent bookings per user
CREATE OR REPLACE FUNCTION enforce_max_concurrent_bookings()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM booking WHERE uid = NEW.uid AND checkin <= NEW.checkout AND checkout >= NEW.checkin) >= 3 THEN
        RAISE EXCEPTION 'User cannot have more than 3 concurrent bookings.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to execute the function before inserting a new booking
CREATE TRIGGER before_booking_insert
BEFORE INSERT ON booking
FOR EACH ROW
EXECUTE FUNCTION enforce_max_concurrent_bookings();


-- 5. Trigger to check availability before booking
CREATE OR REPLACE FUNCTION check_availability()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT (SELECT availability FROM room WHERE rid = NEW.rid) THEN
        RAISE EXCEPTION 'Cannot make booking for a room with false availability';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_booking
BEFORE INSERT ON booking
FOR EACH ROW
EXECUTE FUNCTION check_availability();
