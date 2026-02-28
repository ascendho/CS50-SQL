-- Indexes for harvard.db to speed up typical queries

-- Q1, Q6: enrollments scanned when filtering/joining on student_id
CREATE INDEX "enrollments_student_id"
ON "enrollments"("student_id");

-- Q2, Q3: enrollments scanned when filtering/joining on course_id
CREATE INDEX "enrollments_course_id"
ON "enrollments"("course_id");

-- Q2: courses searched by department, number, and semester together
-- Also helps Q4 (uses leading department= column)
CREATE INDEX "courses_department_number_semester"
ON "courses"("department", "number", "semester");

-- Q3: courses filtered by semester alone
-- (department, number, semester) index cannot efficiently serve semester-only lookups
CREATE INDEX "courses_semester"
ON "courses"("semester");

-- Q5, Q7: courses searched by title (exact or LIKE prefix) and semester
CREATE INDEX "courses_title_semester"
ON "courses"("title", "semester");

-- Q5, Q6: satisfies scanned when filtering by course_id
CREATE INDEX "satisfies_course_id"
ON "satisfies"("course_id");
