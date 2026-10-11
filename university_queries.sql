-- =============================================================================
-- ASSIGNMENT: HOMEWORK 05 - UNIVERSITY DATABASE QUERIES
-- Student Name : Nguyen Dao Bao Ngoc
-- Student ID   : 23070617
-- Course       : INS3064 - Multimedia Design and Web Development
-- Date         : October 2026
-- Description  : 10 SQL queries covering basic SELECT, filtering, sorting,
--                aggregations, GROUP BY, and multi-table JOINs.
-- =============================================================================

USE university_db;

-- =============================================================================
-- Query 1: Basic SELECT
-- =============================================================================
/*
Query 1: Basic SELECT
Description: Retrieve all columns and rows from the students table.
Expected Output: All 5 enrolled students with their academic records.
*/
SELECT * 
FROM students;
/*
+----+--------------+----------------------+--------+------------+-------------------------------+------------+------+---------------+---------------------+
| id | student_code | full_name            | gender | dob        | email                         | phone      | gpa  | department_id | created_at          |
+----+--------------+----------------------+--------+------------+-------------------------------+------------+------+---------------+---------------------+
|  1 | SV2026001    | Nguyễn Đào Bảo Ngọc  | Female | 2004-05-18 | ngoc.nguyen@student.vnu.edu.vn | 0981112231 | 3.82 |             1 | 2026-10-04 22:15:03 |
|  2 | SV2026002    | Đỗ Minh Quân         | Male   | 2004-08-22 | quan.do@student.vnu.edu.vn     | 0981112232 | 3.45 |             1 | 2026-10-04 22:15:03 |
|  3 | SV2026003    | Lê Quỳnh Trang       | Female | 2004-11-10 | trang.le@student.vnu.edu.vn    | 0981112233 | 3.68 |             2 | 2026-10-04 22:15:03 |
|  4 | SV2026004    | Trần Quang Hải       | Male   | 2003-03-15 | hai.tran@student.vnu.edu.vn    | 0981112234 | 3.20 |             3 | 2026-10-04 22:15:03 |
|  5 | SV2026005    | Phạm Hồng Nhung      | Female | 2004-07-30 | nhung.pham@student.vnu.edu.vn  | 0981112235 | 3.75 |             4 | 2026-10-04 22:15:03 |
+----+--------------+----------------------+--------+------------+-------------------------------+------------+------+---------------+---------------------+
(5 rows)
*/

-- =============================================================================
-- Query 2: WHERE with comparison
-- =============================================================================
/*
Query 2: WHERE with comparison
Description: Filter and list students who have a GPA strictly greater than 3.50.
Expected Output: 3 high-achieving students with GPA > 3.50.
*/
SELECT 
    student_code, 
    full_name, 
    gpa 
FROM students 
WHERE gpa > 3.50;
/*
+--------------+----------------------+------+
| student_code | full_name            | gpa  |
+--------------+----------------------+------+
| SV2026001    | Nguyễn Đào Bảo Ngọc  | 3.82 |
| SV2026003    | Lê Quỳnh Trang       | 3.68 |
| SV2026005    | Phạm Hồng Nhung      | 3.75 |
+--------------+----------------------+------+
(3 rows)
*/

-- =============================================================================
-- Query 3: WHERE with AND/OR
-- =============================================================================
/*
Query 3: WHERE with AND/OR
Description: Find courses that have credits >= 3 and belong to either Department 1 or 2.
Expected Output: 2 courses (INS3064 and CSE2010) satisfying both logic branches.
*/
SELECT 
    course_code, 
    title, 
    credits, 
    department_id 
FROM courses 
WHERE credits >= 3 
  AND (department_id = 1 OR department_id = 2);
/*
+-------------+---------------------------------------+---------+---------------+
| course_code | title                                 | credits | department_id |
+-------------+---------------------------------------+---------+---------------+
| INS3064     | Multimedia Design and Web Development |       3 |             1 |
| CSE2010     | Database Management Systems           |       4 |             2 |
+-------------+---------------------------------------+---------+---------------+
(2 rows)
*/

-- =============================================================================
-- Query 4: ORDER BY
-- =============================================================================
/*
Query 4: ORDER BY
Description: Sort all students by their GPA in descending order (highest to lowest).
Expected Output: 5 students ranked from GPA 3.82 down to 3.20.
*/
SELECT 
    student_code, 
    full_name, 
    gpa 
FROM students 
ORDER BY gpa DESC;
/*
+--------------+----------------------+------+
| student_code | full_name            | gpa  |
+--------------+----------------------+------+
| SV2026001    | Nguyễn Đào Bảo Ngọc  | 3.82 |
| SV2026005    | Phạm Hồng Nhung      | 3.75 |
| SV2026003    | Lê Quỳnh Trang       | 3.68 |
| SV2026002    | Đỗ Minh Quân         | 3.45 |
| SV2026004    | Trần Quang Hải       | 3.20 |
+--------------+----------------------+------+
(5 rows)
*/

-- =============================================================================
-- Query 5: LIMIT
-- =============================================================================
/*
Query 5: LIMIT
Description: Return the top 3 highest grade records in the enrollments table.
Expected Output: Top 3 enrollment records with the highest grades.
*/
SELECT 
    id AS enrollment_id, 
    student_id, 
    course_id, 
    grade, 
    grade_letter 
FROM enrollments 
WHERE grade IS NOT NULL 
ORDER BY grade DESC 
LIMIT 3;
/*
+---------------+------------+-----------+-------+--------------+
| enrollment_id | student_id | course_id | grade | grade_letter |
+---------------+------------+-----------+-------+--------------+
|             1 |          1 |         1 |  4.00 | A+           |
|             9 |          5 |         4 |  3.90 | A+           |
|             5 |          3 |         2 |  3.80 | A            |
+---------------+------------+-----------+-------+--------------+
(3 rows)
*/

-- =============================================================================
-- Query 6: LIKE
-- =============================================================================
/*
Query 6: LIKE
Description: Search for faculty members whose name starts with 'TS.' (Doctor of Philosophy).
Expected Output: 2 instructors holding PhD title.
*/
SELECT 
    instructor_code, 
    full_name, 
    email, 
    degree 
FROM instructors 
WHERE full_name LIKE 'TS.%';
/*
+-----------------+--------------------+-----------------------+--------+
| instructor_code | full_name          | email                 | degree |
+-----------------+--------------------+-----------------------+--------+
| INS001          | TS. Nguyễn Văn Hùng | hung.nguyen@vnu.edu.vn | PhD    |
| INS004          | TS. Phạm Minh Tuấn  | tuan.pham@vnu.edu.vn  | PhD    |
+-----------------+--------------------+-----------------------+--------+
(2 rows)
*/

-- =============================================================================
-- Query 7: Aggregate — COUNT / SUM
-- =============================================================================
/*
Query 7: Aggregate — COUNT / SUM
Description: Calculate the total number of courses and the overall sum of credits.
Expected Output: A single aggregated row showing 5 courses and 16 total credits.
*/
SELECT 
    COUNT(id) AS total_courses, 
    SUM(credits) AS total_credits 
FROM courses;
/*
+---------------+---------------+
| total_courses | total_credits |
+---------------+---------------+
|             5 |            16 |
+---------------+---------------+
(1 row)
*/

-- =============================================================================
-- Query 8: Aggregate with GROUP BY + HAVING
-- =============================================================================
/*
Query 8: Aggregate with GROUP BY + HAVING
Description: Group enrollments by course and filter courses having 2 or more students.
Expected Output: Course IDs 1, 2, 3, and 4 which have at least 2 registrations.
*/
SELECT 
    course_id, 
    COUNT(student_id) AS total_enrolled_students 
FROM enrollments 
GROUP BY course_id 
HAVING COUNT(student_id) >= 2 
ORDER BY total_enrolled_students DESC;
/*
+-----------+-------------------------+
| course_id | total_enrolled_students |
+-----------+-------------------------+
|         1 |                       3 |
|         2 |                       2 |
|         3 |                       2 |
|         4 |                       2 |
+-----------+-------------------------+
(4 rows)
*/

-- =============================================================================
-- Query 9: JOIN — two tables
-- =============================================================================
/*
Query 9: JOIN — two tables
Description: Join courses with departments to display course title along with department name.
Expected Output: 5 courses matched with their administering department names.
*/
SELECT 
    c.course_code, 
    c.title AS course_title, 
    c.credits, 
    d.name AS department_name 
FROM courses AS c 
JOIN departments AS d ON c.department_id = d.id 
ORDER BY c.course_code ASC;
/*
+-------------+---------------------------------------+---------+-----------------------------------------------------+
| course_code | course_title                          | credits | department_name                                     |
+-------------+---------------------------------------+---------+-----------------------------------------------------+
| CSE2010     | Database Management Systems           |       4 | Department of Computer Science & Software Engineering |
| ENG2050     | Professional Communication and IELTS |       3 | Department of Applied English Linguistics            |
| FIN2005     | Corporate Financial Modeling          |       3 | Department of International Finance & Banking        |
| INS3064     | Multimedia Design and Web Development |       3 | Department of Applied Information Systems           |
| MGT1002     | Principles of Business Management     |       3 | Department of Business Administration & Analytics    |
+-------------+---------------------------------------+---------+-----------------------------------------------------+
(5 rows)
*/

-- =============================================================================
-- Query 10: JOIN — three or more tables
-- =============================================================================
/*
Query 10: JOIN — three or more tables
Description: Join enrollments, students, courses, and semesters to show full transcript details.
Expected Output: 10 enrollment records displaying student name, course title, semester, and grade.
*/
SELECT 
    s.student_code, 
    s.full_name AS student_name, 
    c.course_code, 
    c.title AS course_title, 
    sem.code AS semester_code, 
    e.grade, 
    e.grade_letter 
FROM enrollments AS e 
JOIN students AS s ON e.student_id = s.id 
JOIN courses AS c ON e.course_id = c.id 
JOIN semesters AS sem ON e.semester_id = sem.id 
ORDER BY s.student_code ASC, sem.code ASC;
/*
+--------------+----------------------+-------------+---------------------------------------+---------------+-------+--------------+
| student_code | student_name         | course_code | course_title                          | semester_code | grade | grade_letter |
+--------------+----------------------+-------------+---------------------------------------+---------------+-------+--------------+
| SV2026001    | Nguyễn Đào Bảo Ngọc  | INS3064     | Multimedia Design and Web Development | FALL2024      |  4.00 | A+           |
| SV2026001    | Nguyễn Đào Bảo Ngọc  | CSE2010     | Database Management Systems           | FALL2024      |  3.70 | A            |
| SV2026002    | Đỗ Minh Quân         | INS3064     | Multimedia Design and Web Development | FALL2024      |  3.50 | B+           |
| SV2026002    | Đỗ Minh Quân         | MGT1002     | Principles of Business Management     | SPRING2025    |  NULL | NULL         |
| SV2026003    | Lê Quỳnh Trang       | CSE2010     | Database Management Systems           | FALL2024      |  3.80 | A            |
| SV2026003    | Lê Quỳnh Trang       | INS3064     | Multimedia Design and Web Development | SPRING2025    |  NULL | NULL         |
| SV2026004    | Trần Quang Hải       | MGT1002     | Principles of Business Management     | FALL2024      |  3.20 | B            |
| SV2026004    | Trần Quang Hải       | FIN2005     | Corporate Financial Modeling          | FALL2024      |  3.00 | B            |
| SV2026005    | Phạm Hồng Nhung      | FIN2005     | Corporate Financial Modeling          | FALL2024      |  3.90 | A+           |
| SV2026005    | Phạm Hồng Nhung      | ENG2050     | Professional Communication and IELTS | SPRING2025    |  NULL | NULL         |
+--------------+----------------------+-------------+---------------------------------------+---------------+-------+--------------+
(10 rows)
*/