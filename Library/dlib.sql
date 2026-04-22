-- ============================================================
--  DIGITAL LIBRARY AUDIT SYSTEM
--  Community College Book Loan & Penalty Tracking
--  Database: MySQL 8.0+
-- ============================================================

-- ----------------------------------------------------------------
-- 0. DATABASE SETUP
-- ----------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS digital_library
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE digital_library;

-- ----------------------------------------------------------------
-- 1. TABLE CREATION (DDL)
-- ----------------------------------------------------------------

-- 1a. Students Table
CREATE TABLE IF NOT EXISTS Students (
    StudentID   INT             NOT NULL AUTO_INCREMENT,
    FullName    VARCHAR(100)    NOT NULL,
    Email       VARCHAR(150)    NOT NULL UNIQUE,
    Phone       VARCHAR(20),
    EnrollDate  DATE            NOT NULL DEFAULT (CURRENT_DATE),
    IsActive    TINYINT(1)      NOT NULL DEFAULT 1,
    PRIMARY KEY (StudentID)
);

-- 1b. Books Table
CREATE TABLE IF NOT EXISTS Books (
    BookID      INT             NOT NULL AUTO_INCREMENT,
    Title       VARCHAR(200)    NOT NULL,
    Author      VARCHAR(150)    NOT NULL,
    ISBN        VARCHAR(20)     NOT NULL UNIQUE,
    Category    VARCHAR(50)     NOT NULL
                    COMMENT 'e.g. Fiction, Science, History, Technology, Arts',
    TotalCopies INT             NOT NULL DEFAULT 1,
    PRIMARY KEY (BookID)
);

-- 1c. IssuedBooks Table  (links Students ↔ Books with loan metadata)
CREATE TABLE IF NOT EXISTS IssuedBooks (
    IssueID     INT             NOT NULL AUTO_INCREMENT,
    StudentID   INT             NOT NULL,
    BookID      INT             NOT NULL,
    IssueDate   DATE            NOT NULL DEFAULT (CURRENT_DATE),
    ReturnDate  DATE            NULL
                    COMMENT 'NULL = book not yet returned',
    PRIMARY KEY (IssueID),
    CONSTRAINT fk_issued_student
        FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_issued_book
        FOREIGN KEY (BookID)    REFERENCES Books(BookID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------------------------------------------
-- 2. SAMPLE DATA  (realistic demo dataset)
-- ----------------------------------------------------------------

INSERT INTO Students (FullName, Email, Phone, EnrollDate) VALUES
    ('Aditya Sharma',    'aditya.sharma@college.edu',  '9876543210', '2021-06-01'),
    ('Priya Nair',       'priya.nair@college.edu',     '9876543211', '2022-01-15'),
    ('Rohit Verma',      'rohit.verma@college.edu',    '9876543212', '2020-03-20'),
    ('Sneha Iyer',       'sneha.iyer@college.edu',     '9876543213', '2023-07-10'),
    ('Karan Mehta',      'karan.mehta@college.edu',    '9876543214', '2019-09-05'),
    ('Divya Pillai',     'divya.pillai@college.edu',   '9876543215', '2021-11-22'),
    ('Arjun Das',        'arjun.das@college.edu',      '9876543216', '2020-08-30'),
    ('Meena Joshi',      'meena.joshi@college.edu',    '9876543217', '2022-04-14'),
    ('Tarun Bose',       'tarun.bose@college.edu',     '9876543218', '2018-12-01'),
    ('Lakshmi Rao',      'lakshmi.rao@college.edu',    '9876543219', '2021-03-17');

INSERT INTO Books (Title, Author, ISBN, Category, TotalCopies) VALUES
    ('The Alchemist',                'Paulo Coelho',        '978-0-06-231500-7', 'Fiction',     5),
    ('A Brief History of Time',      'Stephen Hawking',     '978-0-55-317511-5', 'Science',     3),
    ('Sapiens',                      'Yuval Noah Harari',   '978-0-06-231609-7', 'History',     4),
    ('Clean Code',                   'Robert C. Martin',    '978-0-13-235088-4', 'Technology',  2),
    ('To Kill a Mockingbird',        'Harper Lee',          '978-0-06-112008-4', 'Fiction',     6),
    ('Cosmos',                       'Carl Sagan',          '978-0-34-539136-3', 'Science',     3),
    ('The History of the World',     'J.M. Roberts',        '978-0-19-521043-9', 'History',     2),
    ('Introduction to Algorithms',   'Cormen et al.',       '978-0-26-204630-5', 'Technology',  4),
    ('1984',                         'George Orwell',       '978-0-45-228423-4', 'Fiction',     5),
    ('The Selfish Gene',             'Richard Dawkins',     '978-0-19-286092-7', 'Science',     3),
    ('Guns, Germs and Steel',        'Jared Diamond',       '978-0-39-331755-8', 'History',     2),
    ('Python Crash Course',          'Eric Matthes',        '978-1-59-327603-4', 'Technology',  4),
    ('Pride and Prejudice',          'Jane Austen',         '978-0-14-143951-8', 'Fiction',     4),
    ('The Art of War',               'Sun Tzu',             '978-1-59-030557-4', 'Arts',        3),
    ('Ikigai',                       'Hector Garcia',       '978-0-14-313325-6', 'Arts',        2);

-- IssueDate set in the past to simulate overdue/active/old loans
INSERT INTO IssuedBooks (StudentID, BookID, IssueDate, ReturnDate) VALUES
    -- Overdue: issued >14 days ago, ReturnDate = NULL
    (1,  1,  DATE_SUB(CURRENT_DATE, INTERVAL 20 DAY), NULL),   -- Aditya, Alchemist
    (2,  4,  DATE_SUB(CURRENT_DATE, INTERVAL 17 DAY), NULL),   -- Priya, Clean Code
    (5,  9,  DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY), NULL),   -- Karan, 1984
    (7,  2,  DATE_SUB(CURRENT_DATE, INTERVAL 25 DAY), NULL),   -- Arjun, Brief History
    (8,  6,  DATE_SUB(CURRENT_DATE, INTERVAL 16 DAY), NULL),   -- Meena, Cosmos

    -- Active loans (within 14 days, not yet returned)
    (3,  5,  DATE_SUB(CURRENT_DATE, INTERVAL  5 DAY), NULL),   -- Rohit, Mockingbird
    (4, 12,  DATE_SUB(CURRENT_DATE, INTERVAL  2 DAY), NULL),   -- Sneha, Python Crash Course
    (6,  3,  DATE_SUB(CURRENT_DATE, INTERVAL  8 DAY), NULL),   -- Divya, Sapiens
    (9, 14,  DATE_SUB(CURRENT_DATE, INTERVAL  1 DAY), NULL),   -- Tarun, Art of War
    (10, 15, DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY), NULL),   -- Lakshmi, Ikigai

    -- Returned loans (for popularity stats)
    (1,  9,  DATE_SUB(CURRENT_DATE, INTERVAL 60 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 50 DAY)),  -- Fiction
    (2,  5,  DATE_SUB(CURRENT_DATE, INTERVAL 45 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 38 DAY)),  -- Fiction
    (3,  1,  DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 22 DAY)),  -- Fiction
    (4,  2,  DATE_SUB(CURRENT_DATE, INTERVAL 55 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 46 DAY)),  -- Science
    (5,  6,  DATE_SUB(CURRENT_DATE, INTERVAL 40 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 33 DAY)),  -- Science
    (6,  3,  DATE_SUB(CURRENT_DATE, INTERVAL 70 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 62 DAY)),  -- History
    (7,  8,  DATE_SUB(CURRENT_DATE, INTERVAL 90 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 81 DAY)),  -- Technology
    (8,  12, DATE_SUB(CURRENT_DATE, INTERVAL 20 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 12 DAY)),  -- Technology
    (9,  13, DATE_SUB(CURRENT_DATE, INTERVAL 35 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 28 DAY)),  -- Fiction
    (10, 11, DATE_SUB(CURRENT_DATE, INTERVAL 50 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 43 DAY)),  -- History

    -- Very old loan (for inactive student detection — student 9 & 5 last borrowed >3 yrs ago)
    (9,  7,  DATE_SUB(CURRENT_DATE, INTERVAL 1200 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 1190 DAY)),
    (5,  11, DATE_SUB(CURRENT_DATE, INTERVAL 1100 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 1092 DAY));

-- ----------------------------------------------------------------
-- 3. ANALYTICAL QUERIES
-- ----------------------------------------------------------------

-- ----------------------------------------------------------------
-- 3A. OVERDUE REPORT
--     Books issued more than 14 days ago that have NOT been returned.
--     Shows days overdue and a flat ₹5/day penalty.
-- ----------------------------------------------------------------
SELECT
    s.StudentID,
    s.FullName                                          AS StudentName,
    s.Email,
    b.Title                                             AS BookTitle,
    b.Category,
    ib.IssueDate,
    DATEDIFF(CURRENT_DATE, ib.IssueDate)               AS DaysHeld,
    DATEDIFF(CURRENT_DATE, ib.IssueDate) - 14          AS DaysOverdue,
    CONCAT('₹ ', (DATEDIFF(CURRENT_DATE, ib.IssueDate) - 14) * 5) AS PenaltyAmount
FROM
    IssuedBooks ib
    JOIN Students s ON ib.StudentID = s.StudentID
    JOIN Books    b ON ib.BookID    = b.BookID
WHERE
    ib.ReturnDate IS NULL
    AND DATEDIFF(CURRENT_DATE, ib.IssueDate) > 14
ORDER BY
    DaysOverdue DESC;

-- ----------------------------------------------------------------
-- 3B. POPULARITY INDEX
--     Number of times each category has been borrowed (all time).
--     Useful for procurement decisions.
-- ----------------------------------------------------------------
SELECT
    b.Category,
    COUNT(ib.IssueID)   AS TotalBorrows,
    -- percentage share of total borrows
    ROUND(
        COUNT(ib.IssueID) * 100.0 /
        SUM(COUNT(ib.IssueID)) OVER (),
        2
    )                   AS BorrowSharePct
FROM
    IssuedBooks ib
    JOIN Books b ON ib.BookID = b.BookID
GROUP BY
    b.Category
ORDER BY
    TotalBorrows DESC;

-- ----------------------------------------------------------------
-- 3C. MOST BORROWED INDIVIDUAL BOOKS  (bonus insight)
-- ----------------------------------------------------------------
SELECT
    b.BookID,
    b.Title,
    b.Author,
    b.Category,
    COUNT(ib.IssueID) AS TimesBorrowed
FROM
    IssuedBooks ib
    JOIN Books b ON ib.BookID = b.BookID
GROUP BY
    b.BookID, b.Title, b.Author, b.Category
ORDER BY
    TimesBorrowed DESC
LIMIT 10;

-- ----------------------------------------------------------------
-- 4. DATA CLEANUP — Inactive Student Accounts
--    Identifies students whose LAST borrow was more than 3 years ago
--    (or who have never borrowed at all and enrolled >3 years ago).
--    Step 1 — Preview who will be affected (safe SELECT first).
-- ----------------------------------------------------------------
SELECT
    s.StudentID,
    s.FullName,
    s.Email,
    s.EnrollDate,
    MAX(ib.IssueDate)   AS LastBorrowDate,
    DATEDIFF(CURRENT_DATE, MAX(ib.IssueDate)) AS DaysSinceLastBorrow
FROM
    Students s
    LEFT JOIN IssuedBooks ib ON s.StudentID = ib.StudentID
GROUP BY
    s.StudentID, s.FullName, s.Email, s.EnrollDate
HAVING
    -- Last borrow was more than 3 years (1095 days) ago
    MAX(ib.IssueDate) < DATE_SUB(CURRENT_DATE, INTERVAL 3 YEAR)
    -- OR: student enrolled >3 years ago but has never borrowed
    OR (MAX(ib.IssueDate) IS NULL
        AND s.EnrollDate < DATE_SUB(CURRENT_DATE, INTERVAL 3 YEAR))
ORDER BY
    DaysSinceLastBorrow DESC;

-- ----------------------------------------------------------------
--    Step 2 — Soft delete: mark accounts inactive (RECOMMENDED)
--    This preserves historical loan data while hiding inactive accounts.
-- ----------------------------------------------------------------
UPDATE Students
SET    IsActive = 0
WHERE  StudentID IN (
    SELECT StudentID FROM (
        SELECT s.StudentID
        FROM   Students s
        LEFT JOIN IssuedBooks ib ON s.StudentID = ib.StudentID
        GROUP BY s.StudentID, s.EnrollDate
        HAVING
            MAX(ib.IssueDate) < DATE_SUB(CURRENT_DATE, INTERVAL 3 YEAR)
            OR (MAX(ib.IssueDate) IS NULL
                AND s.EnrollDate < DATE_SUB(CURRENT_DATE, INTERVAL 3 YEAR))
    ) AS inactive
);

-- ----------------------------------------------------------------
--    Step 3 — Hard delete (OPTIONAL / use with caution)
--    Only run this if audit trail is no longer required.
--    Foreign key ON DELETE CASCADE will remove IssuedBooks rows too.
-- ----------------------------------------------------------------
-- DELETE FROM Students
-- WHERE StudentID IN (
--     SELECT StudentID FROM (
--         SELECT s.StudentID
--         FROM   Students s
--         LEFT JOIN IssuedBooks ib ON s.StudentID = ib.StudentID
--         GROUP BY s.StudentID, s.EnrollDate
--         HAVING
--             MAX(ib.IssueDate) < DATE_SUB(CURRENT_DATE, INTERVAL 3 YEAR)
--             OR (MAX(ib.IssueDate) IS NULL
--                 AND s.EnrollDate < DATE_SUB(CURRENT_DATE, INTERVAL 3 YEAR))
--     ) AS inactive
-- );

-- ----------------------------------------------------------------
-- 5. VERIFICATION QUERIES  (run after each step to confirm results)
-- ----------------------------------------------------------------

-- All students and their active status
SELECT StudentID, FullName, Email, IsActive FROM Students ORDER BY StudentID;

-- All issued books with computed overdue flag
SELECT
    ib.IssueID,
    s.FullName,
    b.Title,
    ib.IssueDate,
    ib.ReturnDate,
    CASE
        WHEN ib.ReturnDate IS NULL AND DATEDIFF(CURRENT_DATE, ib.IssueDate) > 14
            THEN 'OVERDUE'
        WHEN ib.ReturnDate IS NULL
            THEN 'Active'
        ELSE 'Returned'
    END AS LoanStatus
FROM IssuedBooks ib
JOIN Students s ON ib.StudentID = s.StudentID
JOIN Books    b ON ib.BookID    = b.BookID
ORDER BY ib.IssueDate DESC;

-- ============================================================
-- END OF SCRIPT
-- ============================================================