--1. List all users and their total number of reviews:
SELECT u.uid, u.name, u.total_reviews
FROM "user" u;


--2. Display hotels with their average ratings:
SELECT h.pid, h.title, AVG(r.rating) as avg_rating
FROM hotel h
JOIN review r ON h.pid = r.pid
GROUP BY h.pid, h.title;
