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

