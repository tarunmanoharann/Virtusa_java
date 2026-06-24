--Ques--

1. SQL: The "Digital Library" Audit
Business Case: A local community college has a database of books and student borrows.
They are struggling to track •Overdue" books and want to know which categories of books are
most popular to decide what to buy next.

Problem Statement
Create a relational system to track book loans and generate a "Penalty Report" for books not
returned within 14 days.

Student Tasks:
1.Table Creation: Create Books, Students, and IssuedBooks (with IssueDate and
RetumDate).
2.Overdue Logic: Write a query to find all students who haven't retumed a book where
the IssueDate was more than 14 days ago and ReturnDate is NULL.
3.Popularity Index: Use COUNT and GROUP BY on the Category column to show which
genre (e.g., Fiction, Science, History) is borrowed the most.
4.Data Cleanup: Write a DELETE or UPDATE statement to remove student records who
haven't borrowed a book in over 3 years (Inactive accounts).

Deliverable: A .sql file containing the DDL (table creation) and the analytical queries.

---

## ER Diagram

+------------------+
|    Students      |
+------------------+
| StudentID (PK)   |
| StudentName      |
+------------------+
         |
         | M 1
+------------------+
|   IssuedBooks    |
+------------------+
| IssueID (PK)     |
| StudentID (FK)   |
| BookID (FK)      |
| IssueDate        |
| ReturnDate       |
+------------------+
         |
         | M 1
+------------------+
|      Books       |
+------------------+
| BookID (PK)      |
| Title            |
| Category         |
+------------------+

**Relationship:**
- One **Student** can have many **IssuedBooks** records (1:M)
- One **Book** can appear in many **IssuedBooks** records (1:M)

**Foreign Keys:**
- `StudentID` → `Students(StudentID)`
- `BookID` → `Books(BookID)` 


**MySQL CLI**
```bash
# Log in to MySQL
mysql -u root -p

# Run the script
mysql -u root -p < dilib.sql
```

pwd : tarun