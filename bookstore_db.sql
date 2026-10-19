-- =============================================================================
-- HOMEWORK 06: BOOKSTORE DATABASE SCHEMA AND SAMPLE DATA
-- Student Name : Nguyen Dao Bao Ngoc
-- Student ID   : 23070617
-- Course       : INS3064 - Multimedia Design and Web Development
-- Date         : October 2026
-- =============================================================================

/*
================================================================================
NORMALIZATION EXPLANATION (3NF COMPLIANCE):
--------------------------------------------------------------------------------
1NF (First Normal Form):
- All attributes contain atomic (single) values.
- Multi-valued attributes such as multiple authors or multiple categories per book
  are separated into junction tables (book_authors, book_categories) instead of 
  being stored as comma-separated strings.

2NF (Second Normal Form):
- Satisfies 1NF.
- All non-key attributes fully depend on the primary key. In junction tables with 
  composite primary keys (book_id, author_id), there are no partial dependencies.

3NF (Third Normal Form):
- Satisfies 2NF.
- No transitive dependencies exist. For example, publisher details (address, website)
  are stored in the `publishers` table rather than repeated inside `books`.
  Customer details are isolated in `customers` rather than repeated inside `orders`.
================================================================================
*/

CREATE DATABASE IF NOT EXISTS bookstore_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bookstore_db;

-- Idempotency: Clean drop sequence respecting foreign key dependencies
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS book_categories;
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS publishers;
DROP TABLE IF EXISTS authors;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Table: authors
CREATE TABLE authors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    biography TEXT,
    nationality VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Table: publishers
CREATE TABLE publishers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    address VARCHAR(255),
    website VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3. Table: categories
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_id INT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 4. Table: books
CREATE TABLE books (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    publisher_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    publication_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_book_price CHECK (price > 0),
    CONSTRAINT chk_book_stock CHECK (stock >= 0),
    FOREIGN KEY (publisher_id) REFERENCES publishers(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 5. Table: book_authors (M:N Junction)
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 6. Table: book_categories (M:N Junction)
CREATE TABLE book_categories (
    book_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (book_id, category_id),
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 7. Table: customers
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 8. Table: orders
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    shipping_address TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_order_total CHECK (total_amount >= 0),
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 9. Table: order_items
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_item_qty CHECK (quantity > 0),
    CONSTRAINT chk_item_price CHECK (unit_price > 0),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 10. Table: reviews
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    book_id INT NOT NULL,
    rating INT NOT NULL,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_review_rating CHECK (rating >= 1 AND rating <= 5),
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =============================================================================
-- SAMPLE DATA INSERTION
-- =============================================================================

-- 1. Authors (6 records)
INSERT INTO authors (name, biography, nationality) VALUES
('Abraham Silberschatz', 'Co-author of Database System Concepts', 'American'),
('Henry F. Korth', 'Professor and database researcher', 'American'),
('Jon Duckett', 'Author of best-selling web design books', 'British'),
('Robin Nixon', 'Developer and author of Learning PHP & MySQL', 'British'),
('Robert C. Martin', 'Known as Uncle Bob, author of Clean Code', 'American'),
('Erich Gamma', 'Co-author of Design Patterns', 'Swiss');

-- 2. Publishers (4 records)
INSERT INTO publishers (name, address, website) VALUES
('McGraw-Hill Education', 'New York, NY, USA', 'https://www.mheducation.com'),
('John Wiley & Sons', 'Hoboken, NJ, USA', 'https://www.wiley.com'),
('O\'Reilly Media', 'Sebastopol, CA, USA', 'https://www.oreilly.com'),
('Prentice Hall', 'Upper Saddle River, NJ, USA', 'https://www.pearson.com');

-- 3. Categories (5 records with hierarchy)
INSERT INTO categories (name, description, parent_id) VALUES
('Computer Science', 'General computing and information technology books', NULL),
('Database Systems', 'Relational and NoSQL database architecture', 1),
('Web Development', 'Front-end and back-end web software engineering', 1),
('Software Engineering', 'System architecture and coding principles', 1),
('Programming Languages', 'Specific programming language guides', 1);

-- 4. Books (8 records)
INSERT INTO books (title, isbn, publisher_id, price, stock, publication_date) VALUES
('Database System Concepts (7th Ed)', '9780073523323', 1, 89.99, 25, '2019-02-15'),
('HTML and CSS: Design and Build Websites', '9781118008188', 2, 29.99, 40, '2011-11-08'),
('JavaScript and JQuery: Interactive Front-End', '9781118531648', 2, 35.50, 30, '2014-06-30'),
('Learning PHP, MySQL & JavaScript (6th Ed)', '9781492093824', 3, 49.99, 15, '2021-07-20'),
('Clean Code: A Handbook of Agile Software Craftsmanship', '9780132350884', 4, 42.00, 50, '2008-08-11'),
('Design Patterns: Elements of Reusable Object-Oriented Software', '9780201633610', 4, 54.99, 20, '1994-11-10'),
('Head First SQL', '9780596526849', 3, 38.00, 18, '2007-08-28'),
('Clean Architecture', '9780134494166', 4, 39.99, 22, '2017-09-20');

-- 5. Book_Authors (M:N Junction)
INSERT INTO book_authors (book_id, author_id) VALUES
(1, 1), (1, 2),
(2, 3),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 4),
(8, 5);

-- 6. Book_Categories (M:N Junction)
INSERT INTO book_categories (book_id, category_id) VALUES
(1, 1), (1, 2),
(2, 1), (2, 3),
(3, 1), (3, 3), (3, 5),
(4, 1), (4, 2), (4, 3), (4, 5),
(5, 1), (5, 4),
(6, 1), (6, 4),
(7, 1), (7, 2),
(8, 1), (8, 4);

-- 7. Customers (5 records)
INSERT INTO customers (full_name, email, password_hash, address, phone) VALUES
('Nguyễn Đào Bảo Ngọc', 'ngoc.nguyen@vnu.edu.vn', 'hash_pass_001', '144 Xuan Thuy, Cầu Giấy, Hà Nội', '0981112231'),
('Đỗ Minh Quân', 'quan.do@vnu.edu.vn', 'hash_pass_002', 'Kim Mã, Ba Đình, Hà Nội', '0981112232'),
('Lê Quỳnh Trang', 'trang.le@vnu.edu.vn', 'hash_pass_003', 'Nguyễn Trãi, Thanh Xuân, Hà Nội', '0981112233'),
('Trần Quang Hải', 'hai.tran@vnu.edu.vn', 'hash_pass_004', 'Hoàng Quốc Việt, Cầu Giấy, Hà Nội', '0981112234'),
('Phạm Hồng Nhung', 'nhung.pham@vnu.edu.vn', 'hash_pass_005', 'Trần Đại Nghĩa, Hai Bà Trưng, Hà Nội', '0981112235');

-- 8. Orders (6 records)
INSERT INTO orders (customer_id, order_date, status, total_amount, shipping_address) VALUES
(1, '2026-10-01 10:30:00', 'delivered', 119.98, '144 Xuan Thuy, Cầu Giấy, Hà Nội'),
(1, '2026-10-10 14:15:00', 'shipped', 49.99, '144 Xuan Thuy, Cầu Giấy, Hà Nội'),
(2, '2026-10-05 09:00:00', 'delivered', 65.49, 'Kim Mã, Ba Đình, Hà Nội'),
(3, '2026-10-12 11:20:00', 'processing', 42.00, 'Nguyễn Trãi, Thanh Xuân, Hà Nội'),
(4, '2026-10-15 16:45:00', 'pending', 92.99, 'Hoàng Quốc Việt, Cầu Giấy, Hà Nội'),
(5, '2026-10-18 08:30:00', 'delivered', 38.00, 'Trần Đại Nghĩa, Hai Bà Trưng, Hà Nội');

-- 9. Order_Items (13 records)
INSERT INTO order_items (order_id, book_id, quantity, unit_price, subtotal) VALUES
(1, 1, 1, 89.99, 89.99),
(1, 2, 1, 29.99, 29.99),
(2, 4, 1, 49.99, 49.99),
(3, 2, 1, 29.99, 29.99),
(3, 3, 1, 35.50, 35.50),
(4, 5, 1, 42.00, 42.00),
(5, 6, 1, 54.99, 54.99),
(5, 7, 1, 38.00, 38.00),
(6, 7, 1, 38.00, 38.00),
(1, 3, 1, 35.50, 35.50),
(2, 8, 1, 39.99, 39.99),
(3, 5, 1, 42.00, 42.00),
(4, 1, 1, 89.99, 89.99);

-- 10. Reviews (10 records)
INSERT INTO reviews (customer_id, book_id, rating, comment) VALUES
(1, 1, 5, 'Comprehensive guide to relational databases. Highly recommended for INS3064!'),
(1, 2, 5, 'Beautiful layout and very intuitive for beginners.'),
(2, 1, 4, 'Great theoretical explanations, though quite heavy.'),
(2, 3, 5, 'Interactive examples are extremely helpful for JavaScript.'),
(3, 4, 4, 'Solid introduction to Web Development back-end stack.'),
(3, 5, 5, 'Essential reading for clean architecture and software engineering.'),
(4, 6, 5, 'Classic design patterns book. A must-read.'),
(4, 7, 4, 'Fun way to learn SQL queries step by step.'),
(5, 5, 5, 'Uncle Bob never disappoints with code quality guidelines.'),
(5, 8, 4, 'Complements Clean Code wonderfully.');