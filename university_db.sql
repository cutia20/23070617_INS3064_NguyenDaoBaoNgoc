-- =============================================================================
-- ASSIGNMENT: HOMEWORK 04 - UNIVERSITY COURSE REGISTRATION DATABASE
-- Student Name : Nguyễn Đào Bảo Ngọc
-- Student ID   : 23070617
-- Course       : INS306402 - Multimedia Design and Web Development
-- Date         : 4th October 2026
-- Description  : Database schema with 6 relational tables, constraints,
--                referential integrity (FK), and realistic seed data.
-- =============================================================================

-- =============================================================================
-- 1. DATABASE INITIALIZATION (Idempotent: Clean teardown and recreation)
-- =============================================================================
DROP DATABASE IF EXISTS university_db;
CREATE DATABASE university_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE university_db;

-- =============================================================================
-- 2. TABLE CREATION WITH CONSTRAINTS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Table 1: departments
-- Purpose: Lưu trữ thông tin các khoa / bộ môn học thuật trong trường.
-- -----------------------------------------------------------------------------
CREATE TABLE departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,          -- Mã khoa viết tắt (e.g., IT, BA)
    name VARCHAR(100) NOT NULL UNIQUE,         -- Tên đầy đủ của khoa
    building VARCHAR(50) NOT NULL,             -- Tòa nhà văn phòng khoa
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- Table 2: semesters
-- Purpose: Lưu danh mục các học kỳ (Niên khóa và kỳ học).
-- -----------------------------------------------------------------------------
CREATE TABLE semesters (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,          -- Mã học kỳ (e.g., FALL2024, SPRING2025)
    name VARCHAR(50) NOT NULL,                 -- Tên hiển thị (e.g., Fall Semester 2024)
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- Table 3: instructors
-- Purpose: Thông tin giảng viên, thuộc về một khoa (Quan hệ 1-N với departments).
-- -----------------------------------------------------------------------------
CREATE TABLE instructors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    instructor_code VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    degree ENUM('Master', 'PhD', 'Associate Professor', 'Professor') DEFAULT 'Master',
    department_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_instructors_department 
        FOREIGN KEY (department_id) REFERENCES departments(id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- Table 4: students
-- Purpose: Thông tin sinh viên, thuộc về một khoa chuyên ngành.
-- -----------------------------------------------------------------------------
CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_code VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    dob DATE NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    gpa DECIMAL(3, 2) DEFAULT 0.00,             -- Điểm GPA theo thang 4.00 (e.g., 3.85)
    department_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_student_gpa CHECK (gpa >= 0.00 AND gpa <= 4.00),
    CONSTRAINT fk_students_department 
        FOREIGN KEY (department_id) REFERENCES departments(id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- Table 5: courses
-- Purpose: Danh mục môn học, do một khoa quản lý và một giảng viên phụ trách chính.
-- -----------------------------------------------------------------------------
CREATE TABLE courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(15) NOT NULL UNIQUE,   -- Mã học phần (e.g., INS3064, MAT1093)
    title VARCHAR(150) NOT NULL,
    credits INT NOT NULL DEFAULT 3,
    description TEXT,
    department_id INT NOT NULL,
    instructor_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_course_credits CHECK (credits > 0 AND credits <= 10),
    CONSTRAINT fk_courses_department 
        FOREIGN KEY (department_id) REFERENCES departments(id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_courses_instructor 
        FOREIGN KEY (instructor_id) REFERENCES instructors(id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- Table 6: enrollments (Bảng trung gian kết nối Sinh viên - Môn học - Học kỳ)
-- Purpose: Quản lý đăng ký học phần và ghi nhận điểm đánh giá.
-- -----------------------------------------------------------------------------
CREATE TABLE enrollments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    semester_id INT NOT NULL,
    grade DECIMAL(3, 2) NULL,                  -- Điểm tổng kết thang 4.0 (NULL nếu đang học)
    grade_letter ENUM('A+', 'A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F') NULL,
    enrollment_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Ràng buộc chống sinh viên đăng ký trùng 1 môn trong cùng 1 kỳ
    CONSTRAINT uq_student_course_semester 
        UNIQUE KEY (student_id, course_id, semester_id),
    CONSTRAINT chk_enrollment_grade CHECK (grade >= 0.00 AND grade <= 4.00),
    CONSTRAINT fk_enrollments_student 
        FOREIGN KEY (student_id) REFERENCES students(id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_enrollments_course 
        FOREIGN KEY (course_id) REFERENCES courses(id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_enrollments_semester 
        FOREIGN KEY (semester_id) REFERENCES semesters(id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =============================================================================
-- 3. SEED SAMPLE DATA (Realistic, meaningful Vietnamese academic context)
-- =============================================================================

-- Seed 5 Departments
INSERT INTO departments (code, name, building) VALUES
('IS', 'Department of Applied Information Systems', 'Building G6'),
('CS', 'Department of Computer Science & Software Engineering', 'Building G6'),
('BA', 'Department of Business Administration & Analytics', 'Building G3'),
('FIN', 'Department of International Finance & Banking', 'Building G2'),
('ENG', 'Department of Applied English Linguistics', 'Building G1');

-- Seed 5 Semesters
INSERT INTO semesters (code, name, start_date, end_date) VALUES
('FALL2024', 'Fall Semester 2024', '2024-09-01', '2025-01-15'),
('SPRING2025', 'Spring Semester 2025', '2025-02-01', '2025-06-20'),
('SUMMER2025', 'Summer Semester 2025', '2025-07-01', '2025-08-25'),
('FALL2025', 'Fall Semester 2025', '2025-09-01', '2026-01-15'),
('SPRING2026', 'Spring Semester 2026', '2026-02-01', '2026-06-20');

-- Seed 5 Instructors
INSERT INTO instructors (instructor_code, full_name, email, phone, degree, department_id) VALUES
('INS001', 'TS. Nguyễn Văn Hùng', 'hung.nguyen@vnu.edu.vn', '0901234561', 'PhD', 1),
('INS002', 'ThS. Trần Thị Mai', 'mai.tran@vnu.edu.vn', '0901234562', 'Master', 2),
('INS003', 'PGS.TS. Lê Hoàng Long', 'long.le@vnu.edu.vn', '0901234563', 'Associate Professor', 3),
('INS004', 'TS. Phạm Minh Tuấn', 'tuan.pham@vnu.edu.vn', '0901234564', 'PhD', 4),
('INS005', 'ThS. Hoàng Thu Thảo', 'thao.hoang@vnu.edu.vn', '0901234565', 'Master', 5);

-- Seed 5 Students
INSERT INTO students (student_code, full_name, gender, dob, email, phone, gpa, department_id) VALUES
('SV2026001', 'Nguyễn Đào Bảo Ngọc', 'Female', '2004-05-18', 'ngoc.nguyen@student.vnu.edu.vn', '0981112231', 3.82, 1),
('SV2026002', 'Đỗ Minh Quân', 'Male', '2004-08-22', 'quan.do@student.vnu.edu.vn', '0981112232', 3.45, 1),
('SV2026003', 'Lê Quỳnh Trang', 'Female', '2004-11-10', 'trang.le@student.vnu.edu.vn', '0981112233', 3.68, 2),
('SV2026004', 'Trần Quang Hải', 'Male', '2003-03-15', 'hai.tran@student.vnu.edu.vn', '0981112234', 3.20, 3),
('SV2026005', 'Phạm Hồng Nhung', 'Female', '2004-07-30', 'nhung.pham@student.vnu.edu.vn', '0981112235', 3.75, 4);

-- Seed 5 Courses
INSERT INTO courses (course_code, title, credits, description, department_id, instructor_id) VALUES
('INS3064', 'Multimedia Design and Web Development', 3, 'Comprehensive web programming with PHP, MySQL, MVC and UI design.', 1, 1),
('CSE2010', 'Database Management Systems', 4, 'Relational model, SQL querying, normalization 3NF, and indexing.', 2, 2),
('MGT1002', 'Principles of Business Management', 3, 'Organizational behavior, business strategy, and leadership theories.', 3, 3),
('FIN2005', 'Corporate Financial Modeling', 3, 'Valuation, financial risk management, and capital markets.', 4, 4),
('ENG2050', 'Professional Communication and IELTS', 3, 'Advanced academic writing and speaking presentation competencies.', 5, 5);

-- Seed 10 Enrollments (Showcasing diverse registration scenarios)
INSERT INTO enrollments (student_id, course_id, semester_id, grade, grade_letter, enrollment_date) VALUES
(1, 1, 1, 4.00, 'A+', '2024-09-05'),  -- Bảo Ngọc học Web Dev kỳ Fall 2024 (A+)
(1, 2, 1, 3.70, 'A',  '2024-09-05'),  -- Bảo Ngọc học CSDL kỳ Fall 2024 (A)
(2, 1, 1, 3.50, 'B+', '2024-09-06'),  -- Minh Quân học Web Dev
(2, 3, 2, NULL, NULL, '2025-02-02'),  -- Minh Quân đăng ký Quản trị kỳ sau (chưa có điểm)
(3, 2, 1, 3.80, 'A',  '2024-09-05'),  -- Quỳnh Trang học CSDL
(3, 1, 2, NULL, NULL, '2025-02-02'),  -- Quỳnh Trang đăng ký Web Dev kỳ sau
(4, 3, 1, 3.20, 'B',  '2024-09-07'),  -- Quang Hải học Quản trị
(4, 4, 1, 3.00, 'B',  '2024-09-07'),  -- Quang Hải học Tài chính
(5, 4, 1, 3.90, 'A+', '2024-09-05'),  -- Hồng Nhung học Tài chính
(5, 5, 2, NULL, NULL, '2025-02-03');  -- Hồng Nhung đăng ký Tiếng Anh kỳ sau