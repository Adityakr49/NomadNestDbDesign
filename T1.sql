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


update booking set checkin='2023-12-16' where bid=1;

