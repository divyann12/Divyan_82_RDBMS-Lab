CREATE DATABASE IF NOT EXISTS smart_parking_sys;
USE smart_parking_sys;

-- Step 2: Create Tables with proper constraints
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) NOT NULL,
    vehicle_number VARCHAR(20) NOT NULL,
    CONSTRAINT chk_valid_email CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_phone_length CHECK (LENGTH(phone) BETWEEN 10 AND 15)
);

CREATE TABLE parking_lots (
    lot_id INT AUTO_INCREMENT PRIMARY KEY,
    lot_name VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    total_slots INT NOT NULL CHECK (total_slots > 0),
    CONSTRAINT unq_lot_location UNIQUE (lot_name, location)
);

CREATE TABLE parking_slots (
    slot_id INT AUTO_INCREMENT PRIMARY KEY,
    lot_id INT NOT NULL,
    slot_number INT NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (lot_id) REFERENCES parking_lots(lot_id) ON DELETE CASCADE,
    CONSTRAINT unq_slot_per_lot UNIQUE (lot_id, slot_number)
);

CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    slot_id INT NOT NULL,
    booking_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    release_time DATETIME NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (slot_id) REFERENCES parking_slots(slot_id) ON DELETE CASCADE,
    CONSTRAINT chk_valid_booking_time CHECK (release_time IS NULL OR release_time >= booking_time)
);

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    payment_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE
);

-- Step 3: Insert Sample Data with corrections
-- Insert users
INSERT INTO users (name, email, phone, vehicle_number)
VALUES 
('John Doe', 'john@example.com', '9876543210', 'DL01AB1234'),
('Alice Smith', 'alice@example.com', '9876543211', 'MH12XY4567'),
('Rahul Verma', 'rahul@example.com', '9123456789', 'KA01CD7890');

-- Insert parking lots (removed duplicate)
INSERT INTO parking_lots (lot_name, location, total_slots)
VALUES 
('Lot A', 'Downtown Area', 50),
('Lot B', 'Airport Road', 80),
('Lot C', 'Mall Basement', 100);

-- Insert parking slots (corrected lot_id references)
INSERT INTO parking_slots (lot_id, slot_number, is_available)
VALUES 
(1, 101, TRUE),
(1, 102, TRUE),
(1, 103, TRUE),
(2, 101, TRUE),
(2, 102, TRUE);

-- Step 4: Booking operations with payments
-- Booking 1 with payment
INSERT INTO bookings (user_id, slot_id) VALUES (1, 1);
UPDATE parking_slots SET is_available = FALSE WHERE slot_id = 1;
INSERT INTO payments (booking_id, amount, payment_status) VALUES (1, 50.00, 'completed');

-- Booking 2 with payment
INSERT INTO bookings (user_id, slot_id) VALUES (2, 2);
UPDATE parking_slots SET is_available = FALSE WHERE slot_id = 2;
INSERT INTO payments (booking_id, amount, payment_status) VALUES (2, 50.00, 'completed');

-- Booking 3 with payment
INSERT INTO bookings (user_id, slot_id) VALUES (3, 3);
UPDATE parking_slots SET is_available = FALSE WHERE slot_id = 3;
INSERT INTO payments (booking_id, amount, payment_status) VALUES (3, 50.00, 'completed');

-- Release a booking
UPDATE parking_slots SET is_available = TRUE WHERE slot_id = 1;
UPDATE bookings SET release_time = NOW() WHERE booking_id = 1;

-- Verification queries
SELECT * FROM users WHERE email IN ('john@example.com', 'alice@example.com', 'rahul@example.com');
SELECT * FROM bookings;
SELECT * FROM payments;
SELECT * FROM bookings;
