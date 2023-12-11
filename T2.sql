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


-- Trigger to execute the function after inserting a review
CREATE TRIGGER after_review_insert
AFTER INSERT ON review
FOR EACH ROW
EXECUTE FUNCTION update_review_statistics_insert();
