-- =====================================================================
-- Placement and Skill Tracker - AISSMS Institute of Information Technology
-- DBMS Mini Project (ITPCC309) | MySQL 8.0 | InnoDB | utf8mb4
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. DDL
-- ---------------------------------------------------------------------
DROP DATABASE IF EXISTS placement_tracker;
CREATE DATABASE placement_tracker CHARACTER SET utf8mb4;
USE placement_tracker;

CREATE TABLE student (
  Student_ID INT AUTO_INCREMENT PRIMARY KEY,
  PRN VARCHAR(20) NOT NULL UNIQUE,
  Name VARCHAR(100) NOT NULL,
  Email VARCHAR(100) NOT NULL,
  Phone VARCHAR(15) NOT NULL,
  Department VARCHAR(50) NOT NULL DEFAULT 'Information Technology',
  CGPA DECIMAL(4,2) NOT NULL,
  Backlogs INT NOT NULL DEFAULT 0,
  Placement_Status ENUM('Unplaced','Placed','Opted Out') NOT NULL DEFAULT 'Unplaced',
  CONSTRAINT chk_cgpa CHECK (CGPA BETWEEN 0 AND 10),
  CONSTRAINT chk_backlogs CHECK (Backlogs >= 0)
) ENGINE=InnoDB;

CREATE TABLE company (
  Company_ID INT AUTO_INCREMENT PRIMARY KEY,
  Company_Name VARCHAR(100) NOT NULL UNIQUE,
  Sector VARCHAR(50),
  HR_Email VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE job_drive (
  Drive_ID INT AUTO_INCREMENT PRIMARY KEY,
  Company_ID INT NOT NULL,
  Role_Title VARCHAR(100) NOT NULL,
  Package_LPA DECIMAL(5,2) NOT NULL,
  Min_CGPA DECIMAL(4,2) NOT NULL DEFAULT 0,
  Max_Backlogs INT NOT NULL DEFAULT 0,
  Drive_Date DATE NOT NULL,
  Status ENUM('Upcoming','Completed','Cancelled') DEFAULT 'Upcoming',
  CONSTRAINT chk_package CHECK (Package_LPA > 0),
  CONSTRAINT fk_drive_company FOREIGN KEY (Company_ID)
    REFERENCES company (Company_ID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE skill (
  Skill_ID INT AUTO_INCREMENT PRIMARY KEY,
  Skill_Name VARCHAR(60) NOT NULL UNIQUE,
  Category ENUM('Programming','Database','Web','Cloud','Soft Skill','Core') NOT NULL
) ENGINE=InnoDB;

CREATE TABLE student_skill (
  Student_ID INT NOT NULL,
  Skill_ID INT NOT NULL,
  Proficiency ENUM('Beginner','Intermediate','Advanced') NOT NULL,
  Certified TINYINT(1) DEFAULT 0,
  PRIMARY KEY (Student_ID, Skill_ID),
  CONSTRAINT fk_ss_student FOREIGN KEY (Student_ID)
    REFERENCES student (Student_ID) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_ss_skill FOREIGN KEY (Skill_ID)
    REFERENCES skill (Skill_ID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE drive_skill (
  Drive_ID INT NOT NULL,
  Skill_ID INT NOT NULL,
  Required_Level ENUM('Beginner','Intermediate','Advanced') NOT NULL,
  PRIMARY KEY (Drive_ID, Skill_ID),
  CONSTRAINT fk_ds_drive FOREIGN KEY (Drive_ID)
    REFERENCES job_drive (Drive_ID) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_ds_skill FOREIGN KEY (Skill_ID)
    REFERENCES skill (Skill_ID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE application (
  Application_ID INT AUTO_INCREMENT PRIMARY KEY,
  Student_ID INT NOT NULL,
  Drive_ID INT NOT NULL,
  Applied_On DATE NOT NULL DEFAULT (CURDATE()),
  Status ENUM('Applied','Shortlisted','Rejected','Selected')
    NOT NULL DEFAULT 'Applied',
  UNIQUE KEY uq_student_drive (Student_ID, Drive_ID),
  CONSTRAINT fk_app_student FOREIGN KEY (Student_ID)
    REFERENCES student (Student_ID) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_app_drive FOREIGN KEY (Drive_ID)
    REFERENCES job_drive (Drive_ID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE interview_round (
  Round_ID INT AUTO_INCREMENT PRIMARY KEY,
  Application_ID INT NOT NULL,
  Round_No INT NOT NULL,
  Round_Type ENUM('Aptitude','Technical','HR','Group Discussion') NOT NULL,
  Round_Date DATE,
  Result ENUM('Pending','Cleared','Not Cleared') DEFAULT 'Pending',
  UNIQUE KEY uq_app_round (Application_ID, Round_No),
  CONSTRAINT chk_round CHECK (Round_No > 0),
  CONSTRAINT fk_round_app FOREIGN KEY (Application_ID)
    REFERENCES application (Application_ID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE placement (
  Placement_ID INT AUTO_INCREMENT PRIMARY KEY,
  Application_ID INT NOT NULL UNIQUE,
  Offer_Date DATE NOT NULL,
  Package_LPA DECIMAL(5,2) NOT NULL,
  Joining_Date DATE,
  CONSTRAINT fk_place_app FOREIGN KEY (Application_ID)
    REFERENCES application (Application_ID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE application_log (
  Log_ID INT AUTO_INCREMENT PRIMARY KEY,
  Application_ID INT NOT NULL,
  Old_Status VARCHAR(20),
  New_Status VARCHAR(20),
  Changed_At DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_log_app FOREIGN KEY (Application_ID)
    REFERENCES application (Application_ID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. DML - Sample data
-- ---------------------------------------------------------------------
INSERT INTO student VALUES
(1,'12251IT001','Aarav Patil','aarav.p@example.com','9876500001','Information Technology',8.90,0,'Placed'),
(2,'12251IT002','Isha Kulkarni','isha.k@example.com','9876500002','Information Technology',9.20,0,'Placed'),
(3,'12251IT003','Rohan Deshmukh','rohan.d@example.com','9876500003','Information Technology',7.40,1,'Placed'),
(4,'12251IT004','Sakshi More','sakshi.m@example.com','9876500004','Information Technology',8.10,0,'Unplaced'),
(5,'12251IT005','Tanmay Jadhav','tanmay.j@example.com','9876500005','Information Technology',6.80,2,'Placed'),
(6,'12251IT006','Neha Gaikwad','neha.g@example.com','9876500006','Information Technology',8.50,0,'Unplaced');

INSERT INTO company VALUES
(1,'TechNova Solutions','IT Services','hr@technova.example.com'),
(2,'DataBridge Analytics','Analytics','hr@databridge.example.com'),
(3,'CloudNest Systems','Cloud','hr@cloudnest.example.com'),
(4,'FinServe Technologies','Fintech','hr@finserve.example.com'),
(5,'BuildCore Engineering','Core','hr@buildcore.example.com');

INSERT INTO job_drive VALUES
(1,1,'Software Engineer',6.50,7.00,0,'2026-10-05','Completed'),
(2,1,'Support Engineer',4.00,6.00,2,'2026-10-12','Completed'),
(3,2,'Data Analyst',8.00,7.50,0,'2026-10-20','Completed'),
(4,3,'Cloud Engineer',10.00,8.00,0,'2026-11-10','Upcoming'),
(5,4,'Backend Developer',9.00,7.50,0,'2026-11-15','Upcoming'),
(6,5,'Graduate Trainee',3.50,6.00,2,'2026-10-25','Completed');

INSERT INTO skill VALUES
(1,'Java','Programming'),(2,'Python','Programming'),(3,'SQL','Database'),
(4,'Web Development','Web'),(5,'Cloud Computing','Cloud'),
(6,'Data Structures','Programming'),(7,'Communication','Soft Skill'),(8,'AutoCAD','Core');

INSERT INTO student_skill VALUES
(1,1,'Advanced',1),(1,3,'Intermediate',0),(1,6,'Advanced',0),
(2,2,'Advanced',1),(2,3,'Advanced',1),(2,5,'Intermediate',1),(2,7,'Intermediate',0),
(3,1,'Intermediate',0),(3,3,'Beginner',0),
(4,4,'Advanced',0),(4,2,'Intermediate',0),(4,3,'Intermediate',1),
(5,8,'Intermediate',0),(5,7,'Beginner',0),
(6,5,'Advanced',1),(6,2,'Intermediate',0),(6,6,'Intermediate',0);

INSERT INTO drive_skill VALUES
(1,1,'Intermediate'),(1,3,'Intermediate'),(1,6,'Intermediate'),
(2,7,'Beginner'),(2,3,'Beginner'),
(3,2,'Advanced'),(3,3,'Advanced'),
(4,5,'Advanced'),(4,2,'Intermediate'),
(5,1,'Advanced'),(5,3,'Intermediate'),
(6,8,'Beginner');

INSERT INTO application VALUES
(1,1,1,'2026-09-28','Selected'),(2,2,1,'2026-09-28','Rejected'),
(3,2,3,'2026-10-10','Selected'),(4,3,2,'2026-10-05','Selected'),
(5,4,1,'2026-09-29','Rejected'),(6,4,3,'2026-10-11','Rejected'),
(7,5,6,'2026-10-18','Selected'),(8,6,4,'2026-10-28','Applied'),
(9,2,4,'2026-10-29','Applied'),(10,1,5,'2026-10-30','Applied');

INSERT INTO interview_round VALUES
(1,1,1,'Aptitude','2026-10-01','Cleared'),(2,1,2,'Technical','2026-10-03','Cleared'),
(3,1,3,'HR','2026-10-05','Cleared'),(4,2,1,'Aptitude','2026-10-01','Cleared'),
(5,2,2,'Technical','2026-10-03','Not Cleared'),(6,3,1,'Aptitude','2026-10-18','Cleared'),
(7,3,2,'Technical','2026-10-20','Cleared'),(8,5,1,'Aptitude','2026-10-01','Not Cleared'),
(9,6,1,'Aptitude','2026-10-18','Cleared'),(10,6,2,'Technical','2026-10-20','Not Cleared');

INSERT INTO placement VALUES
(1,1,'2026-10-08',6.50,'2027-07-01'),(2,3,'2026-10-23',8.00,'2027-07-01'),
(3,4,'2026-10-15',4.00,'2027-07-15'),(4,7,'2026-10-28',3.50,'2027-07-15');

-- ---------------------------------------------------------------------
-- 3. View
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_student_profile AS
SELECT s.Student_ID, s.Name, s.CGPA, s.Placement_Status,
  (SELECT COUNT(*) FROM student_skill ss
   WHERE ss.Student_ID = s.Student_ID) AS Skills_Count,
  (SELECT COUNT(*) FROM application a
   WHERE a.Student_ID = s.Student_ID) AS Applications
FROM student s;

-- ---------------------------------------------------------------------
-- 4. Trigger
-- ---------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_application_update
AFTER UPDATE ON application
FOR EACH ROW
BEGIN
  IF OLD.Status <> NEW.Status THEN
    INSERT INTO application_log (Application_ID, Old_Status, New_Status)
    VALUES (NEW.Application_ID, OLD.Status, NEW.Status);
    IF NEW.Status = 'Selected' THEN
      UPDATE student SET Placement_Status = 'Placed'
      WHERE Student_ID = NEW.Student_ID;
    END IF;
  END IF;
END$$
DELIMITER ;

-- ---------------------------------------------------------------------
-- 5. Table contents
-- ---------------------------------------------------------------------
SELECT Student_ID, PRN, Name, CGPA, Backlogs, Placement_Status FROM student;

SELECT Drive_ID, Company_ID, Role_Title, Package_LPA, Min_CGPA, Max_Backlogs, Drive_Date, Status FROM job_drive;

SELECT * FROM application;

-- ---------------------------------------------------------------------
-- 6. Queries
-- ---------------------------------------------------------------------

-- Q1. Placed students with company, role and package (5-table join)
SELECT s.Name, c.Company_Name, d.Role_Title, p.Package_LPA, p.Joining_Date
FROM placement p
JOIN application a ON p.Application_ID = a.Application_ID
JOIN student s ON a.Student_ID = s.Student_ID
JOIN job_drive d ON a.Drive_ID = d.Drive_ID
JOIN company c ON d.Company_ID = c.Company_ID
ORDER BY p.Package_LPA DESC;

-- Q2. Overall placement statistics (aggregates and sub-queries)
SELECT COUNT(*) AS Total_Students,
  SUM(Placement_Status = 'Placed') AS Placed,
  ROUND(100 * SUM(Placement_Status = 'Placed') / COUNT(*), 2) AS Placement_Pct,
  (SELECT ROUND(AVG(Package_LPA), 2) FROM placement) AS Avg_Package_LPA,
  (SELECT MAX(Package_LPA) FROM placement) AS Highest_LPA
FROM student;

-- Q3. Applications and selections per company (GROUP BY, LEFT JOIN)
SELECT c.Company_Name, COUNT(a.Application_ID) AS Applications,
       SUM(a.Status = 'Selected') AS Selected
FROM company c
JOIN job_drive d ON c.Company_ID = d.Company_ID
LEFT JOIN application a ON d.Drive_ID = a.Drive_ID
GROUP BY c.Company_Name
ORDER BY Selected DESC, Applications DESC;

-- Q4. Most demanded skills (HAVING)
SELECT sk.Skill_Name, COUNT(*) AS Drives_Requiring
FROM drive_skill ds
JOIN skill sk ON ds.Skill_ID = sk.Skill_ID
GROUP BY sk.Skill_Name
HAVING COUNT(*) >= 2
ORDER BY Drives_Requiring DESC, sk.Skill_Name;

-- Q5. Students eligible for the CloudNest drive (eligibility check)
SELECT s.Student_ID, s.Name, s.CGPA
FROM student s
JOIN job_drive d ON d.Drive_ID = 4
WHERE s.CGPA >= d.Min_CGPA AND s.Backlogs <= d.Max_Backlogs
ORDER BY s.CGPA DESC;

-- Q6. Skill gap for the FinServe drive (NOT EXISTS)
SELECT s.Name, sk.Skill_Name AS Missing_Skill
FROM student s
JOIN drive_skill ds ON ds.Drive_ID = 5
JOIN skill sk ON sk.Skill_ID = ds.Skill_ID
WHERE NOT EXISTS (SELECT 1 FROM student_skill ss
                  WHERE ss.Student_ID = s.Student_ID
                    AND ss.Skill_ID = ds.Skill_ID)
ORDER BY s.Name, sk.Skill_Name;

-- Q7. Unplaced students with no pending application (NOT EXISTS)
SELECT Student_ID, Name, CGPA
FROM student s
WHERE Placement_Status = 'Unplaced'
  AND NOT EXISTS (SELECT 1 FROM application a
                  WHERE a.Student_ID = s.Student_ID
                    AND a.Status IN ('Applied','Shortlisted'));

-- Q8. Drives paying above the average package (sub-query)
SELECT c.Company_Name, d.Role_Title, d.Package_LPA
FROM job_drive d JOIN company c ON d.Company_ID = c.Company_ID
WHERE d.Package_LPA > (SELECT AVG(Package_LPA) FROM job_drive)
ORDER BY d.Package_LPA DESC;

-- Q9. View: student profile
SELECT * FROM v_student_profile ORDER BY CGPA DESC;

-- ---------------------------------------------------------------------
-- 7. Trigger test (rolled back, data unchanged)
-- ---------------------------------------------------------------------
START TRANSACTION;
UPDATE application SET Status = 'Selected' WHERE Application_ID = 8;
SELECT * FROM application_log;
SELECT Student_ID, Name, Placement_Status FROM student WHERE Student_ID = 6;
ROLLBACK;

-- ---------------------------------------------------------------------
-- 8. Integrity constraint tests
-- Each statement below is EXPECTED TO FAIL. Uncomment one at a time.
-- ---------------------------------------------------------------------
-- CHECK violation (chk_cgpa):
-- INSERT INTO student (PRN, Name, Email, Phone, CGPA) VALUES ('12251IT099', 'Test', 't@x.com', '9999999999', 11.5);

-- UNIQUE violation (uq_student_drive):
-- INSERT INTO application (Student_ID, Drive_ID) VALUES (1, 1);

-- FK RESTRICT violation (fk_drive_company):
-- DELETE FROM company WHERE Company_ID = 1;
