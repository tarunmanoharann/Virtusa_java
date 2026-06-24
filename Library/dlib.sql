CREATE DATABASE IF NOT EXISTS DigitalLibrary;
USE DigitalLibrary;

-- STUDENTS
CREATE TABLE Students (
    StudentID INT AUTO_INCREMENT PRIMARY KEY,
    StudentName VARCHAR(100)
);

-- BOOKS
CREATE TABLE Books (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(100),
    Category VARCHAR(50)
);

-- ISSUED BOOKS
CREATE TABLE IssuedBooks (
    IssueID INT AUTO_INCREMENT PRIMARY KEY,
    StudentID INT,
    BookID INT,
    IssueDate DATE,
    ReturnDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);

-- SAMPLE DATA
INSERT INTO Students (StudentName) VALUES
('Aditya'),
('Priya'),
('Rohit'),
('Sneha'),
('Karan');

INSERT INTO Books (Title, Category) VALUES
('The Alchemist', 'Fiction'),
('History of Time', 'Science'),
('Sapiens', 'History'),
('Clean Code', 'Technology'),
('Ikigai', 'Self Help');

INSERT INTO IssuedBooks (StudentID, BookID, IssueDate, ReturnDate) VALUES
(1,1,CURDATE()-INTERVAL 20 DAY,NULL),
(2,2,CURDATE()-INTERVAL 16 DAY,NULL),
(3,3,CURDATE()-INTERVAL 5 DAY,NULL),
(4,4,CURDATE()-INTERVAL 2 DAY,NULL),
(5,5,CURDATE()-INTERVAL 30 DAY,CURDATE()-INTERVAL 20 DAY);

-- OVERDUE BOOKS REPORT
SELECT
    s.StudentID,
    s.StudentName,
    b.Title,
    ib.IssueDate
FROM IssuedBooks ib
JOIN Students s ON ib.StudentID = s.StudentID
JOIN Books b ON ib.BookID = b.BookID
WHERE ib.ReturnDate IS NULL
  AND ib.IssueDate < CURDATE() - INTERVAL 14 DAY;

-- POPULARITY INDEX
SELECT
    b.Category,
    COUNT(*) AS TotalBorrows
FROM IssuedBooks ib
JOIN Books b ON ib.BookID = b.BookID
GROUP BY b.Category
ORDER BY TotalBorrows DESC;

-- REMOVE INACTIVE STUDENTS
DELETE FROM Students
WHERE StudentID NOT IN (
    SELECT DISTINCT StudentID
    FROM IssuedBooks
    WHERE IssueDate >= CURDATE() - INTERVAL 3 YEAR
);