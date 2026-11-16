-- ============================================================================
-- Course      : INS3064 - Multimedia Design and Web Development
-- Assignment  : Homework 7 - Advanced SQL Queries (Online Bookstore)
-- Student Name: Nguyen Dao Bao Ngoc
-- Student ID  : 23070617
-- Date        : 2026-11-16
-- ============================================================================

USE bookstore_db;

-- ============================================================================
-- JOIN QUERIES (3)
-- ============================================================================

-- Query 1: Books with Authors
-- List all books with their authors. Show book title, ISBN, and author name.
-- Books with multiple authors appear multiple times (one row per author).
SELECT 
    b.title AS book_title,
    b.isbn,
    a.name AS author_name
FROM books b
INNER JOIN book_authors ba ON b.id = ba.book_id
INNER JOIN authors a ON ba.author_id = a.id
ORDER BY b.title ASC, a.name ASC;
/* Expected Output (9 rows):
+-------------------------------------------------------------+---------------+----------------------+
| book_title                                                  | isbn          | author_name          |
+-------------------------------------------------------------+---------------+----------------------+
| Clean Architecture                                          | 9780134494166 | Robert C. Martin     |
| Clean Code: A Handbook of Agile Software Craftsmanship      | 9780132350884 | Robert C. Martin     |
| Database System Concepts (7th Ed)                           | 9780073523323 | Abraham Silberschatz |
| Database System Concepts (7th Ed)                           | 9780073523323 | Henry F. Korth       |
| Design Patterns: Elements of Reusable Object-Oriented Softw | 9780201633610 | Erich Gamma          |
| Head First SQL                                              | 9780596526849 | Robin Nixon          |
| HTML and CSS: Design and Build Websites                     | 9781118008188 | Jon Duckett          |
| JavaScript and JQuery: Interactive Front-End                | 9781118531648 | Jon Duckett          |
| Learning PHP, MySQL & JavaScript (6th Ed)                   | 9781492093824 | Robin Nixon          |
+-------------------------------------------------------------+---------------+----------------------+
*/


-- Query 2: Order Details
-- List all orders with customer name, order date, book title, quantity,
-- and line total (quantity * unit price). Order by order date descending.
SELECT 
    o.id AS order_id,
    c.full_name AS customer_name,
    o.order_date,
    b.title AS book_title,
    oi.quantity,
    (oi.quantity * oi.unit_price) AS line_total
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id
INNER JOIN order_items oi ON o.id = oi.order_id
INNER JOIN books b ON oi.book_id = b.id
ORDER BY o.order_date DESC, o.id DESC;
/* Expected Output (13 rows):
+----------+---------------------+---------------------+--------------------------------------------------+----------+------------+
| order_id | customer_name       | order_date          | book_title                                       | quantity | line_total |
+----------+---------------------+---------------------+--------------------------------------------------+----------+------------+
| 6        | Phạm Hồng Nhung     | 2026-10-18 08:30:00 | Head First SQL                                   | 1        | 38.00      |
| 5        | Trần Quang Hải      | 2026-10-15 16:45:00 | Design Patterns: Elements of Reusable Object-... | 1        | 54.99      |
| 5        | Trần Quang Hải      | 2026-10-15 16:45:00 | Head First SQL                                   | 1        | 38.00      |
| ...      | ...                 | ...                 | ...                                              | ...      | ...        |
| 1        | Nguyễn Đào Bảo Ngọc | 2026-10-01 10:30:00 | Database System Concepts (7th Ed)                | 1        | 89.99      |
+----------+---------------------+---------------------+--------------------------------------------------+----------+------------+
*/


-- Query 3: Books with Publisher and Categories
-- List each book's title, publisher name, and all category names it belongs to
-- using explicit JOINs across 4 tables.
SELECT 
    b.title AS book_title,
    p.name AS publisher_name,
    c.name AS category_name
FROM books b
INNER JOIN publishers p ON b.publisher_id = p.id
INNER JOIN book_categories bc ON b.id = bc.book_id
INNER JOIN categories c ON bc.category_id = c.id
ORDER BY b.title ASC, c.name ASC;
/* Expected Output (19 rows):
+--------------------------------------------------------+-----------------------+-----------------------+
| book_title                                             | publisher_name        | category_name         |
+--------------------------------------------------------+-----------------------+-----------------------+
| Clean Architecture                                     | Prentice Hall         | Computer Science      |
| Clean Architecture                                     | Prentice Hall         | Software Engineering  |
| Clean Code: A Handbook of Agile Software Craftsmanship | Prentice Hall         | Computer Science      |
| Clean Code: A Handbook of Agile Software Craftsmanship | Prentice Hall         | Software Engineering  |
| Database System Concepts (7th Ed)                      | McGraw-Hill Education | Computer Science      |
| Database System Concepts (7th Ed)                      | McGraw-Hill Education | Database Systems      |
| ...                                                    | ...                   | ...                   |
+--------------------------------------------------------+-----------------------+-----------------------+
*/


-- ============================================================================
-- AGGREGATE QUERIES WITH GROUP BY (2)
-- ============================================================================

-- Query 4: Sales by Book
-- For each book, show the total quantity sold and total revenue.
-- Order by total revenue descending.
SELECT 
    b.id AS book_id,
    b.title AS book_title,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity_sold,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_revenue
FROM books b
LEFT JOIN order_items oi ON b.id = oi.book_id
GROUP BY b.id, b.title
ORDER BY total_revenue DESC, b.title ASC;
/* Expected Output (8 rows):
+---------+--------------------------------------------------------+---------------------+---------------+
| book_id | book_title                                             | total_quantity_sold | total_revenue |
+---------+--------------------------------------------------------+---------------------+---------------+
| 1       | Database System Concepts (7th Ed)                      | 2                   | 179.98        |
| 5       | Clean Code: A Handbook of Agile Software Craftsmanship | 2                   | 84.00         |
| 7       | Head First SQL                                         | 2                   | 76.00         |
| 3       | JavaScript and JQuery: Interactive Front-End           | 2                   | 71.00         |
| 2       | HTML and CSS: Design and Build Websites                | 2                   | 59.98         |
| 6       | Design Patterns: Elements of Reusable Object-Oriented  | 1                   | 54.99         |
| 4       | Learning PHP, MySQL & JavaScript (6th Ed)              | 1                   | 49.99         |
| 8       | Clean Architecture                                     | 1                   | 39.99         |
+---------+--------------------------------------------------------+---------------------+---------------+
*/


-- Query 5: Customer Order Summary
-- For each customer, show the number of orders placed and the total amount spent.
-- Include customers with zero orders using LEFT JOIN.
SELECT 
    c.id AS customer_id,
    c.full_name AS customer_name,
    COUNT(DISTINCT o.id) AS total_orders,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY c.id, c.full_name
ORDER BY total_spent DESC, c.full_name ASC;
/* Expected Output (5 rows):
+-------------+---------------------+--------------+-------------+
| customer_id | customer_name       | total_orders | total_spent |
+-------------+---------------------+--------------+-------------+
| 1           | Nguyễn Đào Bảo Ngọc | 2            | 245.46      |
| 3           | Lê Quỳnh Trang      | 1            | 131.99      |
| 2           | Đỗ Minh Quân        | 1            | 107.49      |
| 4           | Trần Quang Hải      | 1            | 92.99       |
| 5           | Phạm Hồng Nhung     | 1            | 38.00       |
+-------------+---------------------+--------------+-------------+
*/


-- ============================================================================
-- SUBQUERIES (2)
-- ============================================================================

-- Query 6: Books Above Average Price
-- List all books whose price is strictly above the average price of all books (47.56).
-- Show book title and price.
SELECT 
    b.title AS book_title,
    b.price
FROM books b
WHERE b.price > (
    SELECT AVG(price) 
    FROM books
)
ORDER BY b.price DESC;
/* Expected Output (3 rows - Average price is ~47.56):
+-------------------------------------------------------------+-------+
| book_title                                                  | price |
+-------------------------------------------------------------+-------+
| Database System Concepts (7th Ed)                           | 89.99 |
| Design Patterns: Elements of Reusable Object-Oriented Softw | 54.99 |
| Learning PHP, MySQL & JavaScript (6th Ed)                   | 49.99 |
+-------------------------------------------------------------+-------+
*/


-- Query 7: Best-Selling Author
-- Find the author(s) whose books have sold the most total quantity.
-- Uses a subquery with MAX() inside HAVING instead of LIMIT to properly handle ties.
SELECT 
    a.id AS author_id,
    a.name AS author_name,
    SUM(oi.quantity) AS total_books_sold
FROM authors a
INNER JOIN book_authors ba ON a.id = ba.author_id
INNER JOIN order_items oi ON ba.book_id = oi.book_id
GROUP BY a.id, a.name
HAVING SUM(oi.quantity) = (
    SELECT MAX(author_sales.total_qty)
    FROM (
        SELECT SUM(oi2.quantity) AS total_qty
        FROM book_authors ba2
        INNER JOIN order_items oi2 ON ba2.book_id = oi2.book_id
        GROUP BY ba2.author_id
    ) AS author_sales
)
ORDER BY a.name ASC;
/* Expected Output (2 rows tied at 3 copies sold):
+-----------+------------------+------------------+
| author_id | author_name      | total_books_sold |
+-----------+------------------+------------------+
| 5         | Robert C. Martin | 3                |
| 4         | Robin Nixon      | 3                |
+-----------+------------------+------------------+
*/


-- ============================================================================
-- HAVING CLAUSE (1)
-- ============================================================================

-- Query 8: Prolific Reviewers
-- Find customers who have written more than 2 reviews with a rating of 3 or higher.
-- Show customer name and the count of qualifying reviews.
SELECT 
    c.id AS customer_id,
    c.full_name AS customer_name,
    COUNT(r.id) AS positive_review_count
FROM customers c
INNER JOIN reviews r ON c.id = r.customer_id
WHERE r.rating >= 3
GROUP BY c.id, c.full_name
HAVING COUNT(r.id) > 2
ORDER BY positive_review_count DESC, c.full_name ASC;
/* Expected Output (0 rows with current sample data):
+-------------+---------------+-----------------------+
| customer_id | customer_name | positive_review_count |
+-------------+---------------+-----------------------+
| (Empty set - each customer in Homework 6 sample data has 2 reviews) |
+-------------+---------------+-----------------------+
Note: Filtering with WHERE r.rating >= 3 happens before GROUP BY, and HAVING COUNT(r.id) > 2 
filters groups strictly greater than 2. If a customer adds a 3rd review with rating >= 3, they appear here.
*/


-- ============================================================================
-- VIEW CREATION (1)
-- ============================================================================

-- Query 9: Create a Book Sales Summary View
-- Create a view summarizing book details, publisher, sales metrics, and review metrics.
-- Uses derived tables (subqueries) before LEFT JOIN to avoid row multiplication.
CREATE OR REPLACE VIEW v_book_sales_summary AS
SELECT 
    b.id AS book_id,
    b.title AS book_title,
    b.isbn,
    p.name AS publisher_name,
    COALESCE(sales.total_quantity_sold, 0) AS total_quantity_sold,
    COALESCE(sales.total_revenue, 0) AS total_revenue,
    rev.average_rating,
    COALESCE(rev.review_count, 0) AS review_count
FROM books b
INNER JOIN publishers p ON b.publisher_id = p.id
LEFT JOIN (
    SELECT 
        book_id,
        SUM(quantity) AS total_quantity_sold,
        SUM(quantity * unit_price) AS total_revenue
    FROM order_items
    GROUP BY book_id
) AS sales ON b.id = sales.book_id
LEFT JOIN (
    SELECT 
        book_id,
        ROUND(AVG(rating), 2) AS average_rating,
        COUNT(id) AS review_count
    FROM reviews
    GROUP BY book_id
) AS rev ON b.id = rev.book_id;

-- Demonstrate the created view by querying it:
SELECT 
    book_title,
    isbn,
    publisher_name,
    total_quantity_sold,
    total_revenue,
    average_rating,
    review_count
FROM v_book_sales_summary
ORDER BY total_revenue DESC, book_title ASC;
/* Expected Output (8 rows):
+--------------------------------------------------------+---------------+-----------------------+---------------------+---------------+----------------+--------------+
| book_title                                             | isbn          | publisher_name        | total_quantity_sold | total_revenue | average_rating | review_count |
+--------------------------------------------------------+---------------+-----------------------+---------------------+---------------+----------------+--------------+
| Database System Concepts (7th Ed)                      | 9780073523323 | McGraw-Hill Education | 2                   | 179.98        | 4.50           | 2            |
| Clean Code: A Handbook of Agile Software Craftsmanship | 9780132350884 | Prentice Hall         | 2                   | 84.00         | 5.00           | 2            |
| Head First SQL                                         | 9780596526849 | O'Reilly Media        | 2                   | 76.00         | 4.00           | 1            |
| JavaScript and JQuery: Interactive Front-End           | 9781118531648 | John Wiley & Sons     | 2                   | 71.00         | 5.00           | 1            |
| HTML and CSS: Design and Build Websites                | 9781118008188 | John Wiley & Sons     | 2                   | 59.98         | 5.00           | 1            |
| Design Patterns: Elements of Reusable Object-Oriented  | 9780201633610 | Prentice Hall         | 1                   | 54.99         | 5.00           | 1            |
| Learning PHP, MySQL & JavaScript (6th Ed)              | 9781492093824 | O'Reilly Media        | 1                   | 49.99         | 4.00           | 1            |
| Clean Architecture                                     | 9780134494166 | Prentice Hall         | 1                   | 39.99         | 4.00           | 1            |
+--------------------------------------------------------+---------------+-----------------------+---------------------+---------------+----------------+--------------+
*/


-- ============================================================================
-- COMBINED COMPLEX QUERY (1)
-- ============================================================================

-- Query 10: Monthly Revenue Report (Current Year)
-- Show monthly revenue for all 12 months of the current year, including months with zero sales.
-- Combines a derived table via UNION ALL (months 1-12), LEFT JOIN, GROUP BY, and date functions.
SELECT 
    m.month_number,
    MONTHNAME(CONCAT(YEAR(CURDATE()), '-', m.month_number, '-01')) AS month_name,
    COUNT(DISTINCT o.id) AS number_of_orders,
    COALESCE(SUM(oi.quantity), 0) AS total_items_sold,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_revenue
FROM (
    SELECT 1 AS month_number UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
    SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL
    SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL
    SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
) AS m
LEFT JOIN orders o 
    ON MONTH(o.order_date) = m.month_number 
    AND YEAR(o.order_date) = YEAR(CURDATE())
LEFT JOIN order_items oi 
    ON o.id = oi.order_id
GROUP BY m.month_number, month_name
ORDER BY m.month_number ASC;
/* Expected Output (12 rows - All 6 sample orders occurred in October 2026):
+--------------+------------+------------------+------------------+---------------+
| month_number | month_name | number_of_orders | total_items_sold | total_revenue |
+--------------+------------+------------------+------------------+---------------+
| 1            | January    | 0                | 0                | 0.00          |
| ...          | ...        | ...              | ...              | ...           |
| 10           | October    | 6                | 13               | 615.93        |
| 11           | November   | 0                | 0                | 0.00          |
| 12           | December   | 0                | 0                | 0.00          |
+--------------+------------+------------------+------------------+---------------+
*/