# 📚 Digital Library Audit System
### Community College — Book Loan & Penalty Tracking

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Database Schema](#database-schema)
3. [ER Diagram](#er-diagram)
4. [How to Run](#how-to-run)
5. [Query Reference](#query-reference)
6. [Business Logic Explained](#business-logic-explained)
7. [Sample Output](#sample-output)
8. [Design Decisions](#design-decisions)

---

## Project Overview

A MySQL-based relational system built for a community college library to:

| Goal | Solution |
|------|----------|
| Track which books are loaned out | `IssuedBooks` table with `ReturnDate = NULL` for active loans |
| Flag overdue books (>14 days) | `DATEDIFF` query on `IssueDate` with a NULL `ReturnDate` check |
| Calculate penalty per student | ₹5/day × days overdue |
| Rank categories by popularity | `COUNT + GROUP BY` on `Category` |
| Clean up inactive student accounts | `UPDATE`/`DELETE` for accounts with no borrow in the last 3 years |

---

## Database Schema

### `Students`
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `StudentID` | INT | PK, AUTO_INCREMENT | Unique student identifier |
| `FullName` | VARCHAR(100) | NOT NULL | Student's full name |
| `Email` | VARCHAR(150) | NOT NULL, UNIQUE | Contact email |
| `Phone` | VARCHAR(20) | — | Optional phone number |
| `EnrollDate` | DATE | NOT NULL, DEFAULT today | Date of enrollment |
| `IsActive` | TINYINT(1) | DEFAULT 1 | 1 = active, 0 = deactivated |

---

### `Books`
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `BookID` | INT | PK, AUTO_INCREMENT | Unique book identifier |
| `Title` | VARCHAR(200) | NOT NULL | Book title |
| `Author` | VARCHAR(150) | NOT NULL | Author name |
| `ISBN` | VARCHAR(20) | NOT NULL, UNIQUE | International Standard Book Number |
| `Category` | VARCHAR(50) | NOT NULL | Genre: Fiction / Science / History / Technology / Arts |
| `TotalCopies` | INT | DEFAULT 1 | Number of physical copies owned |

---

### `IssuedBooks`
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `IssueID` | INT | PK, AUTO_INCREMENT | Unique loan record ID |
| `StudentID` | INT | FK → Students | Who borrowed the book |
| `BookID` | INT | FK → Books | Which book was borrowed |
| `IssueDate` | DATE | NOT NULL, DEFAULT today | When the book was issued |
| `ReturnDate` | DATE | NULL allowed | When returned; NULL = still out |

**Foreign Keys:**
- `StudentID` → `Students(StudentID)` — `ON DELETE CASCADE ON UPDATE CASCADE`
- `BookID` → `Books(BookID)` — `ON DELETE CASCADE ON UPDATE CASCADE`

---

## ER Diagram

```
┌─────────────┐           ┌──────────────────┐           ┌──────────────┐
│  Students   │           │   IssuedBooks    │           │    Books     │
│─────────────│           │──────────────────│           │──────────────│
│ StudentID PK│──────────<│ IssueID       PK │>──────────│ BookID    PK │
│ FullName    │  1      M │ StudentID     FK │ M      1  │ Title        │
│ Email       │           │ BookID        FK │           │ Author       │
│ Phone       │           │ IssueDate        │           │ ISBN         │
│ EnrollDate  │           │ ReturnDate       │           │ Category     │
│ IsActive    │           └──────────────────┘           │ TotalCopies  │
└─────────────┘                                          └──────────────┘
```

Relationship:
- One **Student** can have many **IssuedBooks** records (1:M)
- One **Book** can appear in many **IssuedBooks** records (1:M)

---

## How to Run

### Prerequisites
- MySQL 8.0 or higher
- MySQL CLI, MySQL Workbench, DBeaver, or any compatible client

### Steps

**Option A — MySQL CLI**
```bash
# Log in to MySQL
mysql -u root -p

# Run the script
mysql -u root -p < digital_library.sql
```

**Option B — MySQL Workbench**
1. Open MySQL Workbench and connect to your server
2. Go to **File → Open SQL Script**
3. Select `digital_library.sql`
4. Click the **⚡ Execute** button (or press `Ctrl + Shift + Enter`)

**Option C — phpMyAdmin**
1. Click on **Import** tab
2. Choose `digital_library.sql`
3. Click **Go**

---

## Query Reference

### Query 1 — Overdue Penalty Report
**File section:** `-- 3A. OVERDUE REPORT`

```sql
SELECT s.StudentID, s.FullName, b.Title, ib.IssueDate,
       DATEDIFF(CURRENT_DATE, ib.IssueDate) - 14 AS DaysOverdue,
       CONCAT('₹ ', (DATEDIFF(CURRENT_DATE, ib.IssueDate) - 14) * 5) AS PenaltyAmount
FROM IssuedBooks ib
JOIN Students s ON ib.StudentID = s.StudentID
JOIN Books    b ON ib.BookID    = b.BookID
WHERE ib.ReturnDate IS NULL
  AND DATEDIFF(CURRENT_DATE, ib.IssueDate) > 14
ORDER BY DaysOverdue DESC;
```

**Logic:**
- `ReturnDate IS NULL` → book is still out
- `DATEDIFF(...) > 14` → past the 14-day grace period
- Penalty = `(DaysHeld - 14) × ₹5`

---

### Query 2 — Category Popularity Index
**File section:** `-- 3B. POPULARITY INDEX`

```sql
SELECT b.Category,
       COUNT(ib.IssueID) AS TotalBorrows,
       ROUND(COUNT(ib.IssueID) * 100.0 / SUM(COUNT(ib.IssueID)) OVER(), 2) AS BorrowSharePct
FROM IssuedBooks ib
JOIN Books b ON ib.BookID = b.BookID
GROUP BY b.Category
ORDER BY TotalBorrows DESC;
```

**Logic:**
- `COUNT + GROUP BY Category` tallies all borrow events per genre
- Window function `SUM(...) OVER()` computes the grand total without a subquery
- Result guides the library's procurement decisions

---

### Query 3 — Inactive Account Cleanup
**File section:** `-- 4. DATA CLEANUP`

**Step 1 — Preview (non-destructive SELECT)**
```sql
SELECT s.StudentID, s.FullName, MAX(ib.IssueDate) AS LastBorrowDate
FROM Students s
LEFT JOIN IssuedBooks ib ON s.StudentID = ib.StudentID
GROUP BY s.StudentID
HAVING MAX(ib.IssueDate) < DATE_SUB(CURRENT_DATE, INTERVAL 3 YEAR)
    OR (MAX(ib.IssueDate) IS NULL AND s.EnrollDate < DATE_SUB(CURRENT_DATE, INTERVAL 3 YEAR));
```

**Step 2 — Soft delete (recommended)**
```sql
UPDATE Students SET IsActive = 0 WHERE StudentID IN (...subquery...);
```

**Step 3 — Hard delete (optional)**
```sql
-- DELETE FROM Students WHERE StudentID IN (...subquery...);
```

> ⚠️ The DELETE is commented out by default. Uncomment only after confirming you no longer need historical records.

---

## Business Logic Explained

| Rule | Implementation |
|------|----------------|
| 14-day loan limit | `DATEDIFF(CURRENT_DATE, IssueDate) > 14 AND ReturnDate IS NULL` |
| ₹5/day penalty | `(DaysHeld - 14) * 5` |
| Book still out | `ReturnDate IS NULL` |
| Inactive account | Last borrow > 3 years ago OR never borrowed + enrolled > 3 years ago |
| Soft vs Hard delete | `UPDATE IsActive = 0` preserves audit trail; `DELETE` removes records permanently |

---

## Sample Output

### Overdue Report
| StudentName | BookTitle | IssueDate | DaysOverdue | PenaltyAmount |
|-------------|-----------|-----------|-------------|---------------|
| Karan Mehta | 1984 | (30 days ago) | 16 | ₹ 80 |
| Arjun Das | A Brief History of Time | (25 days ago) | 11 | ₹ 55 |
| Aditya Sharma | The Alchemist | (20 days ago) | 6 | ₹ 30 |

### Popularity Index
| Category | TotalBorrows | BorrowSharePct |
|----------|-------------|----------------|
| Fiction | 8 | 36.36% |
| Science | 5 | 22.73% |
| Technology | 4 | 18.18% |
| History | 3 | 13.64% |
| Arts | 2 | 9.09% |

---

## Design Decisions

| Decision | Rationale |
|----------|-----------|
| `ReturnDate` is nullable | NULL semantically means "not yet returned"; avoids placeholder dates |
| Soft delete (`IsActive`) | Preserves audit history while hiding inactive accounts from queries |
| `ON DELETE CASCADE` | Ensures referential integrity; removing a student/book cleans up loan records |
| `utf8mb4` charset | Full Unicode support, including emoji and multilingual names |
| Subquery wrapper in UPDATE/DELETE | MySQL doesn't allow direct self-referencing in UPDATE; the nested subquery is the standard workaround |
| Window function for percentage | Avoids a double aggregation subquery; cleaner and more readable |

---

*Generated for: Community College Digital Library Audit System*  
*Database Engine: MySQL 8.0+ | Encoding: utf8mb4*