--Queries using Triggers and Views:
--1)Trigger to update the availability status of a room when a booking is made:
CREATE OR REPLACE FUNCTION update_room_availability()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE room
    SET availability = FALSE
    WHERE rid = NEW.rid;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_booking_insert
AFTER INSERT ON booking
FOR EACH ROW
EXECUTE FUNCTION update_room_availability();


--2)Trigger to update the total price of a booking when the check-in date is modified:
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


--3)Trigger function for review insertion:
CREATE OR REPLACE FUNCTION update_review_statistics_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Update total_reviews in "user" table
    UPDATE "user"
    SET total_reviews = total_reviews + 1
    WHERE uid = NEW.uid;

    -- Update avgrating in "hotel" table
    UPDATE hotel
    SET avgrating = (
        SELECT AVG(rating)
        FROM review
        WHERE pid = NEW.pid
    )
    WHERE pid = NEW.pid;

    -- Update avgrating in "room" table
    UPDATE room
    SET avgrating = (
        SELECT AVG(rating)
        FROM review
        WHERE rid = NEW.rid
    )
    WHERE rid = NEW.rid;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to execute the function after inserting a review
CREATE TRIGGER after_review_insert
AFTER INSERT ON review
FOR EACH ROW
EXECUTE FUNCTION update_review_statistics_insert();


--4)Trigger function for review deletion:
CREATE OR REPLACE FUNCTION update_review_statistics_delete()
RETURNS TRIGGER AS $$
BEGIN
    -- Update total_reviews in "user" table
    UPDATE "user"
    SET total_reviews = total_reviews - 1
    WHERE uid = OLD.uid;

    -- Update avgrating in "hotel" table
    UPDATE hotel
    SET avgrating = (
        SELECT AVG(rating)
        FROM review
        WHERE pid = OLD.pid
    )
    WHERE pid = OLD.pid;

    -- Update avgrating in "room" table
    UPDATE room
    SET avgrating = (
        SELECT AVG(rating)
        FROM review
        WHERE rid = OLD.rid
    )
    WHERE rid = OLD.rid;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger to execute the function after deleting a review
CREATE TRIGGER after_review_delete
AFTER DELETE ON review
FOR EACH ROW
EXECUTE FUNCTION update_review_statistics_delete();


