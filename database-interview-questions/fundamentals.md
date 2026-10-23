# Database Fundamentals Interview Questions & Answers

> **Module:** Database Interview Preparation  
> **Topic:** Database vs DBMS, Relational vs NoSQL, SQL vs NoSQL, Keys, Normalization, ACID  
> **Target Audience:** Junior to Senior Software Engineers, Data Engineers

---

## Difficulty Navigation
- [Beginner Level](#beginner-level)
- [Intermediate Level](#intermediate-level)
- [Advanced Level](#advanced-level)

---

## Beginner Level

### Q1: What is the fundamental difference between a Database and a DBMS?
#### Short Interview-Ready Answer
"A database is an organized collection of structured or unstructured data stored persistently on disk. A Database Management System (DBMS) is the software suite (e.g., PostgreSQL, MySQL, Oracle) that provides the tools, storage engines, security controls, transaction coordinators, and query processors required to create, query, update, and administer that database."

---

### Q2: What are the ACID properties in database transactions?
#### Short Interview-Ready Answer
"ACID stands for:
- **Atomicity:** All statements in a transaction complete successfully, or all changes are rolled back ('all-or-nothing').
- **Consistency:** A transaction transitions the database from one valid state to another, preserving all schemas, constraints, and triggers.
- **Isolation:** Concurrent transactions execute without interfering with one another; intermediate uncommitted states are hidden.
- **Durability:** Once a transaction is committed, its modifications survive crashes, power cuts, and restarts via the Write-Ahead Log (WAL)."

---

## Intermediate Level

### Q3: What is the difference between Primary Key, Candidate Key, Foreign Key, and Surrogate Key?
#### Short Interview-Ready Answer
"- **Candidate Key:** Any column or minimal set of columns that uniquely identifies a row in a table.
- **Primary Key:** The single candidate key chosen by the database designer as the authoritative row identifier (strictly non-null and unique).
- **Foreign Key:** A column that establishes a referential constraint pointing to the primary key of another table.
- **Surrogate Key:** An artificial, system-generated identifier (e.g., auto-incrementing `BIGSERIAL` or `UUID`) having no intrinsic business meaning, used purely for row identification."

---

### Q4: Explain 1NF, 2NF, 3NF, and BCNF with concrete rules.
#### Short Interview-Ready Answer
"- **1NF (First Normal Form):** Every column contains atomic (indivisible) values; no repeating groups or arrays.
- **2NF (Second Normal Form):** Must be in 1NF, and all non-key attributes must be fully functionally dependent on the entire primary key (eliminates partial key dependencies in composite keys).
- **3NF (Third Normal Form):** Must be in 2NF, and no non-key attribute may depend on another non-key attribute (eliminates transitive dependencies).
- **BCNF (Boyce-Codd Normal Form):** A stricter version of 3NF where for every functional dependency $X \to Y$, $X$ must be a superkey."

---

## Advanced Level

### Q5: When is Denormalization deliberately preferred over 3NF in production systems?
#### Short Interview-Ready Answer
"Denormalization is deliberately adopted in read-heavy applications, data warehouses, and distributed architectures to trade write overhead and storage space for dramatic read performance improvements. By pre-joining tables and storing redundant fields (such as duplicating `customer_name` on an `orders` record), we eliminate expensive multi-table JOINs, reduce CPU and memory usage, and enable single-shard query routing in distributed architectures."

---

## Authoritative References
- [Database System Concepts (Silberschatz, Korth, Sudarshan)](https://www.db-book.com/)
- [PostgreSQL Transaction Semantics](https://www.postgresql.org/docs/current/tutorial-transactions.html)
