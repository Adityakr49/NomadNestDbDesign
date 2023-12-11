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


INSERT INTO "user" (uid, name, email, password, role, total_reviews) VALUES (1, 'John Doe', 'john@example.com', 'password123', 'customer', 0);

-- Insert a hotel
INSERT INTO hotel (pid, uid, title, address, description, perks, checkin, checkout, avgrating) VALUES
  (1, 1, 'Example Hotel', '123 Main St', 'A wonderful place to stay', 'Free Wi-Fi, Parking', '14:00:00', '12:00:00', 0.0);

-- Insert a room
INSERT INTO room (rid, pid, name, maxguest, availability, price, avgrating) VALUES
  (1, 1, 'Room 101', 2, TRUE, 100.00, 0.0);

-- Insert a booking
INSERT INTO booking (bid, uid, pid, rid, checkin, checkout, name, phone, price) VALUES
  (1, 1, 1, 1, '2023-01-01', '2023-01-03', 'Booking 1', '1234567890', 200.00);

-- Insert a review
INSERT INTO review (reviewid, bid, rating, comment) VALUES (1, 1, 4.5, 'Great experience!');
-- Insert another review with the bid corresponding to a booking
INSERT INTO review (reviewid, bid, rating, comment) VALUES (2, 1, 3.8, 'Good service.');


-- Select updated user, hotel, and room data
SELECT * FROM "user" WHERE uid = 1;
SELECT * FROM hotel WHERE pid = 1;
SELECT * FROM room WHERE rid = 1;

-- Delete a review (this should trigger the after_review_delete trigger)
DELETE FROM review WHERE reviewid = 2;

SELECT * FROM "user" WHERE uid = 1;
SELECT * FROM hotel WHERE pid = 1;
SELECT * FROM room WHERE rid = 1;
