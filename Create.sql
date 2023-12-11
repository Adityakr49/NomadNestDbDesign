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
    uid INT REFERENCES "user"(uid),
    pid INT REFERENCES hotel(pid),
    rid INT REFERENCES room(rid),
    rating DECIMAL(2, 1),
    comment TEXT
);
