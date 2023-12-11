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

-- Insert a user
INSERT INTO "user" (uid, name, email, password, role, total_reviews) VALUES (1, 'John Doe', 'john@example.com', 'password123', 'customer', 0);

-- Insert a hotel
INSERT INTO hotel (pid, uid, title, address, description, perks, checkin, checkout, avgrating) VALUES
  (1, 1, 'Example Hotel', '123 Main St', 'A wonderful place to stay', 'Free Wi-Fi, Parking', '14:00:00', '12:00:00', 0.0);


-- Insert rooms
INSERT INTO room (rid, pid, name, maxguest, availability, price, avgrating) VALUES
  (1, 1, 'Room 101', 2, TRUE, 100.00, 0.0),
  (2, 1, 'Room 102', 2, TRUE, 120.00, 0.0),
  (3, 1, 'Room 103', 3, TRUE, 150.00, 0.0);

-- Insert bookings that violate the constraint
-- This user will have 3 concurrent bookings
-- Insert four concurrent bookings
INSERT INTO booking (bid, uid, pid, rid, checkin, checkout, name, phone, price) VALUES
  (1, 1, 1, 1, '2023-01-01', '2023-01-04', 'Booking 1', '1234567890', 200.00),
  (2, 1, 1, 2, '2023-01-02', '2023-01-05', 'Booking 2', '1234567890', 240.00),
  (3, 1, 1, 3, '2023-01-03', '2023-01-06', 'Booking 3', '1234567890', 300.00),
  (4, 1, 1, 1, '2023-01-04', '2023-01-07', 'Booking 4', '1234567890', 250.00);

