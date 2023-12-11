-- Insert values into the "user" table
INSERT INTO "user" (name, email, password, role, total_reviews)
VALUES
  ('Arohi Aditya', 'aditya@example.com', 'namaste123', 'admin', 0),
  ('Priya Singh', 'priya@example.com', 'pyaar@123', 'customer', 0),
  ('Aarav Gupta', 'aarav@example.com', 'ganesha456', 'customer', 0),
  ('Meera Desai', 'meera@example.com', 'devi@123', 'customer', 0),
  ('Akash Verma', 'akash@example.com', 'dilse123', 'customer', 0);
  
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
  (1, 1, 1, '2023-12-15', '2023-12-20', 'Arohi Aditya', '9876543210', 25000.00),
  (2, 2, 4, '2023-12-12', '2023-12-18', 'Priya Singh', '8765432109', 18000.00),
  (3, 3, 7, '2023-12-08', '2023-12-15', 'Aarav Gupta', '7654321098', 24000.00),
  (4, 1, 2, '2023-12-02', '2023-12-06', 'Meera Desai', '7890123456', 15000.00),
  (5, 2, 5, '2023-12-05', '2023-12-10', 'Akash Verma', '8901234567', 22000.00);

-- Insert values into the "review" table
INSERT INTO review (uid, pid, rid, rating, comment)
VALUES
  (1, 1, 1, 4.5, 'An amazing experience at the Taj Mahal Hotel. The staff was very courteous, and the facilities were top-notch.'),
  (2, 2, 4, 4.0, 'Great business hotel with excellent amenities. The meeting rooms were well-equipped, and the staff was professional.'),
  (3, 3, 7, 4.8, 'Serenity Retreat lived up to its name. The natural surroundings and peaceful atmosphere made it a perfect getaway.'),
  (4, 1, 2, 4.2, 'The Taj Suite was spacious and well-designed. The view of the Taj Mahal from the room was breathtaking.'),
  (5, 2, 5, 4.7, 'The Business Suite provided a comfortable stay. The business amenities were convenient for my work trip.');
  SELECT * FROM "user";
  SELECT * FROM hotel;
  SELECT * FROM booking;
  SELECT * FROM room;
  SELECT * FROM review;
  INSERT INTO booking (uid, pid, rid, checkin, checkout, name, phone, price)
VALUES
  (1, 1, 3, '2023-12-23', '2023-12-24', 'Arohi Aditya', '9876543210', 12000.00);
  SELECT * FROM room;
