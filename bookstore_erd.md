# Entity-Relationship Diagram (ERD) - Online Bookstore System

## 1. System Entities and Attributes

### 1. authors
- id (INT, PK, AUTO_INCREMENT)
- name (VARCHAR(100), NOT NULL)
- biography (TEXT)
- nationality (VARCHAR(50))
- created_at (TIMESTAMP)

### 2. publishers
- id (INT, PK, AUTO_INCREMENT)
- name (VARCHAR(100), NOT NULL, UNIQUE)
- address (VARCHAR(255))
- website (VARCHAR(100))
- created_at (TIMESTAMP)

### 3. categories
- id (INT, PK, AUTO_INCREMENT)
- name (VARCHAR(100), NOT NULL, UNIQUE)
- description (TEXT)
- parent_id (INT, FK -> categories.id, NULLABLE)
- created_at (TIMESTAMP)

### 4. books
- id (INT, PK, AUTO_INCREMENT)
- title (VARCHAR(255), NOT NULL)
- isbn (VARCHAR(20), NOT NULL, UNIQUE)
- publisher_id (INT, FK -> publishers.id)
- price (DECIMAL(10,2), NOT NULL)
- stock (INT, NOT NULL, DEFAULT 0)
- publication_date (DATE)
- created_at (TIMESTAMP)

### 5. book_authors (Junction Table: books to authors)
- book_id (INT, PK, FK -> books.id)
- author_id (INT, PK, FK -> authors.id)

### 6. book_categories (Junction Table: books to categories)
- book_id (INT, PK, FK -> books.id)
- category_id (INT, PK, FK -> categories.id)

### 7. customers
- id (INT, PK, AUTO_INCREMENT)
- full_name (VARCHAR(100), NOT NULL)
- email (VARCHAR(100), NOT NULL, UNIQUE)
- password_hash (VARCHAR(255), NOT NULL)
- address (TEXT)
- phone (VARCHAR(20))
- created_at (TIMESTAMP)

### 8. orders
- id (INT, PK, AUTO_INCREMENT)
- customer_id (INT, FK -> customers.id)
- order_date (DATETIME, NOT NULL)
- status (ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
- total_amount (DECIMAL(10,2), NOT NULL)
- shipping_address (TEXT, NOT NULL)
- created_at (TIMESTAMP)

### 9. order_items
- id (INT, PK, AUTO_INCREMENT)
- order_id (INT, FK -> orders.id)
- book_id (INT, FK -> books.id)
- quantity (INT, NOT NULL)
- unit_price (DECIMAL(10,2), NOT NULL)
- subtotal (DECIMAL(10,2), NOT NULL)

### 10. reviews
- id (INT, PK, AUTO_INCREMENT)
- customer_id (INT, FK -> customers.id)
- book_id (INT, FK -> books.id)
- rating (INT, CHECK 1 to 5)
- comment (TEXT)
- created_at (TIMESTAMP)

---

## 2. Relationships and Cardinality

- publishers to books: 1:N (One publisher publishes many books)
- books to authors: M:N (Resolved via book_authors junction table)
- books to categories: M:N (Resolved via book_categories junction table)
- customers to orders: 1:N (One customer places many orders)
- orders to order_items: 1:N (One order contains many order items)
- books to order_items: 1:N (One book can be ordered in many order items)
- customers to reviews: 1:N (One customer writes many reviews)
- books to reviews: 1:N (One book receives many reviews)