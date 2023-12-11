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

-- Insert a user
INSERT INTO "user" (uid, name, email, password, role, total_reviews) VALUES (1, 'John Doe', 'john@example.com', 'password123', 'customer', 0);

-- Insert a hotel
INSERT INTO hotel (pid, uid, title, address, description, perks, checkin, checkout, avgrating) VALUES
  (1, 1, 'Example Hotel', '123 Main St', 'A wonderful place to stay', 'Free Wi-Fi, Parking', '14:00:00', '12:00:00', 0.0);

-- Insert a room
INSERT INTO room (rid, pid, name, maxguest, availability, price, avgrating) VALUES
  (1, 1, 'Room 101', 2, TRUE, 100.00, 0.0);

-- Insert a booking
INSERT INTO booking (bid, uid, pid, rid, checkin, checkout, name, phone, price) VALUES
  (1, 1, 1, 1, '2023-01-02', '2023-01-03', 'Booking 1', '1234567890', 100.00);
-- Select the updated booking
SELECT * FROM booking WHERE bid = 1;

-- -- Update the check-in date for the booking
UPDATE booking
SET checkin = '2023-01-01'
WHERE bid = 1;
-- Select the updated booking
SELECT * FROM booking WHERE bid = 1;

