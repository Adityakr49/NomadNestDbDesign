-- Trigger to update total_reviews in "user" table, avgrating in "hotel" table, and avgrating in "room" table
CREATE OR REPLACE FUNCTION update_review_statistics()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the operation is an INSERT
    IF TG_OP = 'INSERT' THEN
        -- Update total_reviews in "user" table
        UPDATE "user"
        SET total_reviews = total_reviews + 1
        WHERE uid = NEW.uid;

    -- Check if the operation is a DELETE
    ELSIF TG_OP = 'DELETE' THEN
        -- Update total_reviews in "user" table
        UPDATE "user"
        SET total_reviews = total_reviews - 1
        WHERE uid = OLD.uid;

    END IF;

    -- Update avgrating in "hotel" table
    UPDATE hotel
    SET avgrating = (
        SELECT AVG(rating)
        FROM review
        WHERE pid = NEW.pid
    )
    WHERE pid = COALESCE(NEW.pid, OLD.pid);

    -- Update avgrating in "room" table
    UPDATE room
    SET avgrating = (
        SELECT AVG(rating)
        FROM review
        WHERE rid = NEW.rid
    )
    WHERE rid = COALESCE(NEW.rid, OLD.rid);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to execute the function after inserting or deleting a review
CREATE TRIGGER after_review_insert_or_delete
AFTER INSERT OR DELETE ON review
FOR EACH ROW
EXECUTE FUNCTION update_review_statistics();
