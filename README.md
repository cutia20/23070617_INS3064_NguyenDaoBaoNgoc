# INS3064 - Homework 04: University Database Design

## 1. Student Information
- **Full Name:** Nguyen Dao Bao Ngoc
- **Student ID:** 23070617
- **Course:** INS3064 - Multimedia Design and Web Development
- **Semester:** Fall 2026

---

## 2. Video Demonstration
- **YouTube Link (Unlisted):** [Watch Video on YouTube](https://youtu.be/FlotQqVSphA)
- **Direct URL:** `https://youtu.be/FlotQqVSphA`

---

## 3. Database Schema Overview
The database `university_db` includes 6 relational tables designed with 3NF normalization:
1. `departments`: Stores academic departments.
2. `semesters`: Stores semester timeline definitions.
3. `instructors`: Faculty members referencing `departments` (1:N).
4. `students`: Enrolled students referencing `departments` (1:N).
5. `courses`: Subject catalogs assigned to instructors and departments.
6. `enrollments`: Junction table resolving M:N relationship between students and courses with a composite `UNIQUE KEY (student_id, course_id, semester_id)`.

---

## 4. Technical Constraints & Data Integrity
- **Idempotent Execution:** Includes `DROP DATABASE IF EXISTS` and clean table definitions.
- **Strict Validation:** 
  - `CHECK (gpa >= 0.00 AND gpa <= 4.00)` on GPA fields.
  - `ENUM` used for fixed value sets (`gender`, `degree`, `grade_letter`).
  - `DATE` chosen for dates to optimize storage without unnecessary time stamps.
  - Composite `UNIQUE KEY` in `enrollments` prevents duplicate course registrations within a semester.

---

## 5. How to Run
Import `university_db.sql` directly into phpMyAdmin or execute via MySQL CLI:
```bash
mysql -u root -p < university_db.sql