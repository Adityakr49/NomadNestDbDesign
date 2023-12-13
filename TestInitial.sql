CREATE TABLE "user" (
    uid SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(50) NOT NULL,
    role VARCHAR(20) CHECK (role IN ('admin', 'customer')),
    total_reviews INT DEFAULT 0
);

CREATE TABLE hotel (
    pid SERIAL PRIMARY KEY,
    uid INT REFERENCES "user"(uid),
    title VARCHAR(100) NOT NULL,
    address TEXT,
    description TEXT,
    perks TEXT,
    checkin TIME,
    checkout TIME,
    avgrating DECIMAL(2, 1)
);

CREATE TABLE room (
    rid SERIAL PRIMARY KEY,
    pid INT REFERENCES hotel(pid),
    name VARCHAR(100),
    maxguest INT,
    availability BOOLEAN DEFAULT TRUE,
    price DECIMAL(10, 2),
    avgrating DECIMAL(2, 1)
);

CREATE TABLE booking (
    bid SERIAL PRIMARY KEY,
    uid INT REFERENCES "user"(uid),
    pid INT REFERENCES hotel(pid),
    rid INT REFERENCES room(rid),
    checkin DATE CHECK (checkin < checkout),
    checkout DATE,
    name VARCHAR(100),
    phone VARCHAR(15),
    price DECIMAL(10, 2)
);

CREATE TABLE review (
    reviewid SERIAL PRIMARY KEY,
    bid INT REFERENCES booking(bid),
    rating DECIMAL(2, 1),
    comment TEXT
);

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





INSERT INTO "user" (name, email, password, role, total_reviews)
VALUES
  ('Arohi Arman', 'arman@example.com', 'secret', 'admin', 0),
  ('Priya Oberoi', 'priya@example.com', 'pass@123', 'customer', 0),
  ('Aarav Gupta', 'aarav@example.com', 'password', 'customer', 0),
  ('Meera Desai', 'meera@example.com', 'key@123', 'customer', 0),
  ('Akash Verma', 'akash@example.com', 'secret123', 'customer', 0);
  
  INSERT INTO hotel (uid, title, address, description, perks, checkin, checkout, avgrating)
VALUES
  (1, 'Taj Mahal Hotel', '1 Agra Road', 'Experience luxury near the Taj Mahal.', 'Spa, Rooftop Dining', '14:00', '12:00', 0),
  (2, 'Business Hub Inn', '35 Corporate Street', 'Ideal for business travelers and professionals.', 'Business Center, Meeting Rooms', '12:00', '11:00', 0),
  (3, 'Serenity Retreat', '22 Tranquil Lane', 'Escape to a peaceful retreat surrounded by nature.', 'Yoga Retreat, Meditation Garden', '15:00', '10:00', 0);
  
  
  INSERT INTO room (pid, name, maxguest, price, avgrating)
VALUES
  (1, 'Deluxe Room 101', 2, 5000.00, 0),
  (1, 'Taj Suite 201', 3, 8000.00, 0),
  (1, 'Presidential Suite 301', 4, 12000.00, 0),
  (2, 'Executive Corporate Room', 2, 4000.00, 0),
  (2, 'Business Suite', 3, 6000.00, 0),
  (2, 'Penthouse Suite', 4, 10000.00, 0),
  (3, 'Yoga Retreat Room', 2, 3500.00, 0),
  (3, 'Meditation Suite', 3, 5500.00, 0),
  (3, 'Nature View Cottage', 2, 4500.00, 0);
  
  INSERT INTO booking (uid, pid, rid, checkin, checkout, name, phone, price)
VALUES
  (1, 1, 1, '2023-12-15', '2023-12-20', 'Arohi Arman', '9876543210', 25000.00);
  
  
  
  
  
  
  
  
  

  update booking set checkin='2023-12-16' where bid=1;
  
  --done trigger 1
  
  
  
  
  
  
  
  
  
  
  
  --Trigger 2
  INSERT INTO booking (uid, pid, rid, checkin, checkout, name, phone, price)
VALUES
  (2, 2, 4, '2023-12-12', '2023-12-18', 'Priya Oberoi', '8765432109', 18000.00),
  (3, 3, 7, '2023-12-08', '2023-12-15', 'Aarav Gupta', '7654321098', 24000.00),
  (4, 1, 2, '2023-12-02', '2023-12-06', 'Meera Desai', '7890123456', 15000.00),
  (5, 2, 5, '2023-12-05', '2023-12-10', 'Akash Verma', '8901234567', 22000.00);

-- Insert values into the "review" table
INSERT INTO review (bid, rating, comment)
VALUES
  (1, 4.5, 'An amazing experience at the Taj Mahal Hotel. The staff was very courteous, and the facilities were top-notch.'),
  (2, 4.0, 'Great business hotel with excellent amenities. The meeting rooms were well-equipped, and the staff was professional.'),
  (3, 4.8, 'Serenity Retreat lived up to its name. The natural surroundings and peaceful atmosphere made it a perfect getaway.'),
  (4, 4.2, 'The Taj Suite was spacious and well-designed. The view of the Taj Mahal from the room was breathtaking.'),
  (5, 4.7, 'The Business Suite provided a comfortable stay. The business amenities were convenient for my work trip.');
  
  
  
  
  
  
  
  
  
  --trigger 3
  delete from review where reviewid=1;
  
  
  --trigger 4
  INSERT INTO booking (uid, pid, rid, checkin, checkout, name, phone, price) VALUES
  (1, 1, 1, '2023-01-01', '2023-01-04', 'Booking 1', '1234567890', 25000.00),
  (1, 1, 2, '2023-01-02', '2023-01-05', 'Booking 2', '1234567890', 25000.00),
  (1, 1, 3, '2023-01-03', '2023-01-06', 'Booking 3', '1234567890', 15000.00),
  (1, 1, 1, '2023-01-04', '2023-01-07', 'Booking 4', '1234567890', 15000.00);
  
  
  
--trigger 5 
update room set availability=false where rid=1;



INSERT INTO booking (uid, pid, rid, checkin, checkout, name, phone, price)
VALUES
  (1, 1, 1, '2023-12-29', '2023-12-31', 'Arohi Arman', '9876543210', 10000.00);
