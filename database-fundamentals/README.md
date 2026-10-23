# Database Fundamentals Module

This module covers the core theoretical, logical, and structural foundations of relational and non-relational database management systems.

---

## Documents in this Module

| Concept Guide | Focus Area | Key Concepts |
| :--- | :--- | :--- |
| **[Database vs DBMS](database-vs-dbms.md)** | Core Definitions | Data on disk vs storage engine software, database architectures, client-server models. |
| **[Relational vs NoSQL](relational-vs-nosql.md)** | Paradigm Comparison | Structured schema vs dynamic schemaless, tabular vs document/key-value/graph/wide-column. |
| **[SQL vs NoSQL](sql-vs-nosql.md)** | Query Languages & Scalability | Declarative relational algebra vs API-driven query interfaces, ACID vs BASE. |
| **[Database Keys](database-keys.md)** | Relational Identity | Primary, Super, Candidate, Alternate, Foreign, Surrogate, and Composite keys. |
| **[Normalization and Denormalization](normalization-and-denormalization.md)** | Relational Modeling | 1NF, 2NF, 3NF, BCNF, insertion/update/deletion anomalies, strategic OLAP denormalization. |
| **[Database Indexes](indexes.md)** | Search Data Structures | B-Tree search mechanics, leaf page traversal, Hash, GIN, GiST, BRIN index types. |
| **[Database Transactions](transactions.md)** | Concurrency & Execution | Transaction boundaries (`BEGIN ... COMMIT`), savepoints, rollbacks, and transaction lifecycle. |
| **[ACID Properties](acid-properties.md)** | Reliability Guarantees | Atomicity (all-or-nothing), Consistency (integrity), Isolation (visibility), Durability (WAL fsync). |
| **[Isolation Levels](isolation-levels.md)** | Concurrency Control | Read Uncommitted, Read Committed, Repeatable Read, Serializable; dirty/phantom reads; MVCC. |
