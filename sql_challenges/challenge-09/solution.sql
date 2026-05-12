Today's Challenge
-- Lesson 04: Setup
-- Create a simple accounts table for the transfer demo
DROP TABLE accounts PURGE;
CREATE TABLE accounts (
    account_id   NUMBER PRIMARY KEY,
    owner_name   VARCHAR2(50) NOT NULL,
    balance      NUMBER(10,2) NOT NULL CHECK (balance >= 0)
);
INSERT INTO accounts VALUES (1, 'Alice',  1000.00);
INSERT INTO accounts VALUES (2, 'Bob',     500.00);
INSERT INTO accounts VALUES (3, 'Charlie', 250.00);
COMMIT;
-- Verify starting state
SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;
-- Expected: Alice=1000, Bob=500, Charlie=250
 
 
-- Lesson 04: Class Exercises
-- Students: work through these in order. Don't skip the verify steps.
-- ============================================================
-- EXERCISE 1: Manual transaction (warm-up)
-- ============================================================
-- Transfer $50 from Charlie (3) to Alice (1) using BEGIN / COMMIT manually.
-- Before: verify balances. After COMMIT: verify again.
-- Your SQL here:

SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;

UPDATE accounts SET balance = balance - 50 WHERE account_id = 3;
UPDATE accounts SET balance = balance + 50 WHERE account_id = 1;
COMMIT;

SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;

-- ============================================================
-- EXERCISE 2: Catch yourself with ROLLBACK
-- ============================================================
-- Start a transfer of $10,000 from Bob (2) to Charlie (3).
-- Before committing, check the balances. Does Bob have enough?
-- Use ROLLBACK to undo. Verify balances restored.
-- Your SQL here:

UPDATE accounts SET balance = balance - 10000 WHERE account_id = 2;
UPDATE accounts SET balance = balance + 10000 WHERE account_id = 3;

SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;

ROLLBACK;

SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;

-- ============================================================
-- EXERCISE 3: SAVEPOINT checkpoint
-- ============================================================
-- You need to:
-- 1. Add $25 to Alice's balance
-- 2. Set a savepoint
-- 3. Deduct $25 from Charlie's balance (wrong account — you meant Bob)
-- 4. Rollback to savepoint
-- 5. Deduct $25 from Bob's balance instead
-- 6. Commit
-- Your SQL here:

UPDATE accounts SET balance = balance + 25 WHERE account_id = 1;
SAVEPOINT before_deduction;

UPDATE accounts SET balance = balance - 25 WHERE account_id = 3;
ROLLBACK TO before_deduction;

UPDATE accounts SET balance = balance - 25 WHERE account_id = 2;
COMMIT;

-- ============================================================
-- EXERCISE 4: Write your own stored procedure
-- ============================================================
-- Create a procedure called deposit_funds(p_account_id, p_amount)
-- It should:
-- 1. Validate that p_amount > 0 (raise error if not)
-- 2. Add p_amount to the account balance
-- 3. COMMIT on success
-- 4. ROLLBACK + re-raise on any error
-- Test it with: EXEC deposit_funds(3, 75);
-- Your SQL here:

CREATE OR REPLACE PROCEDURE deposit_funds(
    p_account_id IN NUMBER,
    p_amount     IN NUMBER
) AS
BEGIN

    IF p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Deposit amount must be greater than zero.');
    END IF;

    UPDATE accounts 
    SET balance = balance + p_amount 
    WHERE account_id = p_account_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Successfully deposited $' || p_amount || ' to account ' || p_account_id);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Deposit failed. Changes rolled back.');
        RAISE;
END;
/

SET SERVEROUTPUT ON;
EXEC deposit_funds(3, 75);

-- ============================================================
-- EXERCISE 5: Discussion
-- ============================================================
-- Answer these in words (no SQL needed):
-- Q1: You're building a patient appointment booking system.
-- A booking requires:
--   a) Reserve the time slot
--   b) Create the appointment record
--   c) Send a confirmation notification
-- Which of these should be inside the transaction? Which should be outside? Why?
/* ANSWER Q1: 
(a) and (b) should be inside the transaction. They must be atomic; you cannot have a reserved time slot without an appointment record, nor an appointment record for a slot that isn't reserved. If one fails, both must roll back.
(c) should be outside the transaction. Sending a notification (like an email or SMS) is an external action that cannot be rolled back. If the transaction fails and rolls back after sending the email, the patient gets a false confirmation.
*/

-- Q2: Your stored procedure calls COMMIT at the end.
-- A developer calls your procedure from inside their own larger transaction.
-- What problem does this create?
/* ANSWER Q2: 
It breaks the atomicity of the developer's larger transaction. When your procedure issues a commit, it permanently saves not just your procedure's updates, but ALL pending changes made by the developer's outer transaction up to that point. If the developer later encounters an error and tries to ROLLBACK, the changes committed by your procedure (and everything done before it) cannot be undone.
*/

-- Q3: You have a function called calculate_copay() and a procedure called post_payment().
-- A colleague wants to use calculate_copay() inside a SELECT statement.
-- Can they? Can they do the same with post_payment()? Why or why not?
/* ANSWER Q3: 
They can use calculate_copay() inside a SELECT statement. Functions are designed to return values and can be embedded in SQL queries.
They cannot use post_payment() inside a SELECT statement. Procedures do not return a value in a way that SELECT can evaluate, and they typically contain DML (INSERT/UPDATE/DELETE) and transaction control (COMMIT/ROLLBACK), which are strictly forbidden inside a SELECT query.
*/
 
 
-- Lesson 04: Stored Procedures — Package the Logic in the Database
-- ============================================================
-- PART 1: Create the stored procedure
-- ============================================================
CREATE OR REPLACE PROCEDURE transfer_funds(
    p_from_account  IN  NUMBER,
    p_to_account    IN  NUMBER,
    p_amount        IN  NUMBER
) AS
    v_from_balance  NUMBER;
BEGIN
    SELECT balance INTO v_from_balance
    FROM accounts
    WHERE account_id = p_from_account;
    IF v_from_balance < p_amount THEN
        RAISE_APPLICATION_ERROR(-20001, 'Insufficient funds in account ' || p_from_account);
    END IF;
    UPDATE accounts SET balance = balance - p_amount WHERE account_id = p_from_account;
    UPDATE accounts SET balance = balance + p_amount WHERE account_id = p_to_account;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Transfer complete: $' || p_amount || ' from account ' || p_from_account || ' to account ' || p_to_account);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Transfer failed. All changes rolled back.');
        RAISE;  
END;
/

-- ============================================================
-- PART 2: Call the procedure
-- ============================================================
SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;
SET SERVEROUTPUT ON;
EXEC transfer_funds(1, 2, 100);

SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;

-- ============================================================
-- PART 3: What happens with insufficient funds?
-- ============================================================
EXEC transfer_funds(1, 2, 99999);
SELECT account_id, owner_name, balance FROM accounts ORDER BY account_id;

-- ============================================================
-- PART 4: Stored procedure vs function — side by side
-- ============================================================
-- PROCEDURE: does something, can use COMMIT/ROLLBACK
-- Use when: inserting data, updating state, complex multi-step operations
-- Called with: EXEC or CALL — cannot use in SELECT
-- FUNCTION: returns a value, no COMMIT/ROLLBACK
-- Use when: calculations, data transformation
-- Can use in: SELECT, WHERE, HAVING
-- Example function (contrast)
CREATE OR REPLACE FUNCTION get_balance(p_account_id IN NUMBER) RETURN NUMBER AS
    v_balance NUMBER;
BEGIN
    SELECT balance INTO v_balance FROM accounts WHERE account_id = p_account_id;
    RETURN v_balance;
END;
/
-- Function used directly in SELECT
SELECT account_id, owner_name, get_balance(account_id) AS current_balance
FROM accounts;
-- Procedure: CANNOT do this:
-- SELECT transfer_funds(1, 2, 100) FROM dual;  -- ERROR