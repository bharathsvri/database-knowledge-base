# Banking & Financial Ledger Database System Design

> **Category:** Database System Design  
> **Target Scale:** 50 Million Bank Accounts, 10,000 Transfers/Sec, Zero Financial Inconsistency  
> **Primary Technology:** PostgreSQL, Distributed Consensus, Double-Entry Bookkeeping

---

## 1. Core Architectural Mandates
1. **Never use floating-point types (`FLOAT`, `DOUBLE`):** Binary floating-point representation causes roundoff errors (e.g., $0.1 + 0.2 \ne 0.3$). Always use `NUMERIC(15, 2)` or integer cents.
2. **Double-Entry Bookkeeping:** Money cannot be created or destroyed. Every transaction must consist of balanced Debits and Credits whose sum equals exactly zero:
   $$\sum \text{Debits} + \sum \text{Credits} = 0$$
3. **Immutable Ledger (Append-Only):** Never execute `UPDATE accounts SET balance = balance - 100`. Balances are calculated by summing immutable transaction line entries or derived from audited balance snapshots.

---

## 2. Double-Entry Schema Architecture

```sql
-- 1. Accounts Master
CREATE TABLE accounts (
    account_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_number VARCHAR(34) UNIQUE NOT NULL, -- IBAN standard
    currency CHAR(3) NOT NULL, -- ISO 4217 (USD, EUR, GBP)
    account_type VARCHAR(20) NOT NULL, -- ASSET, LIABILITY, EQUITY, REVENUE, EXPENSE
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ DEFAULT clock_timestamp()
);

-- 2. Financial Journal / Transactions Master
CREATE TABLE journal_entries (
    entry_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    idempotency_key VARCHAR(128) UNIQUE NOT NULL, -- Prevents duplicate processing
    description TEXT NOT NULL,
    posted_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp()
);

-- 3. Individual Postings (Legs of the transaction)
CREATE TABLE postings (
    posting_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    entry_id UUID NOT NULL REFERENCES journal_entries (entry_id),
    account_id UUID NOT NULL REFERENCES accounts (account_id),
    amount NUMERIC(15, 2) NOT NULL, -- Positive for Debit, Negative for Credit
    sequence_num INT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT clock_timestamp()
);

-- Composite index for fast balance aggregation
CREATE INDEX idx_postings_account_time ON postings (account_id, created_at);
```

---

## 3. Atomic Fund Transfer Stored Procedure

```sql
CREATE OR REPLACE PROCEDURE transfer_funds(
    p_from_account UUID,
    p_to_account UUID,
    p_amount NUMERIC(15, 2),
    p_idempotency_key VARCHAR(128)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_entry_id UUID;
BEGIN
    IF p_amount <= 0 THEN
        RAISE EXCEPTION 'Transfer amount must be strictly positive';
    END IF;

    -- 1. Create Journal Entry (Fails if idempotency key exists)
    INSERT INTO journal_entries (idempotency_key, description)
    VALUES (p_idempotency_key, 'Account fund transfer')
    RETURNING entry_id INTO v_entry_id;

    -- 2. Post Debit (Decrease from source account)
    INSERT INTO postings (entry_id, account_id, amount, sequence_num)
    VALUES (v_entry_id, p_from_account, -p_amount, 1);

    -- 3. Post Credit (Increase destination account)
    INSERT INTO postings (entry_id, account_id, amount, sequence_num)
    VALUES (v_entry_id, p_to_account, p_amount, 2);

    -- Transaction commits automatically; double-entry balance mathematically verified!
END;
$$;
```

---

## 4. Authoritative References
- [Martin Fowler: Accounting Patterns](https://martinfowler.com/eaaDev/AccountingNarrative.html)
- [PostgreSQL Stored Procedures](https://www.postgresql.org/docs/current/sql-createprocedure.html)
