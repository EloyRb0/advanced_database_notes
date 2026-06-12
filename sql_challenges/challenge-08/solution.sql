-- Exercise 1 — Find the slow query
--
-- Run this query. Look at the execution plan.
-- Is Oracle using an index? Should it?
-- A: No, Oracle is not using an index. Because of the amount of entries in the current table performance does not seem to be 
-- that slow, however as the table grows it will become a problem, and also if filtering by site_id is a common query, then it
-- would definitely be worth it as a good practice.

SELECT * FROM patient_visits WHERE site_id = 3;

-- Questions:
-- a) What scan type do you see? Why?
-- A: Full table scan, because there are no indexes on that column, so it has to scan the whole table for entries that fit the constraints
-- b) site_id has values 1–5. Is this high or low cardinality?
-- A: This is low cardinality, because there are only 5 distinct values in the column, and there are likely many entries for each value.
-- c) Would adding an index on site_id help? Why or why not?
-- A: Adding an index on site_id would help if filtering by site_id is a common query, because it would allow the database to quickly find
-- the relevant entries without having to scan the entire table. However, since site_id has low cardinality, it may not be as vital
-- for the system as a column with high cardinality, but it should still be considered and tested


--======================================================
-- Exercise 2 — Create an index and see if it helps
--
-- Create an index on visit_date.
-- Then run the range query below and check the plan.
--======================================================

-- Step 1: Create it
CREATE INDEX idx_patient_visits_date ON patient_visits(visit_date);

-- Step 2: Gather stats
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'PATIENT_VISITS', cascade => TRUE);
END;
/

-- Step 3: Run the range query and check the plan
SELECT * FROM patient_visits
WHERE visit_date BETWEEN SYSDATE - 30 AND SYSDATE;

-- Questions:
-- a) Does Oracle use the index for this range?
-- A: Yes, Oracle uses the index for this range query
-- b) Change the range to the last 7 days. Does the plan change?
-- A: No, the plan does not change, Oracle still uses the index for the last 7 days range query
-- c) Change to the last 700 days. What happens?
-- A: Oracle still uses the index for the last 700 days range query, but it may not be as efficient as it is for smaller ranges, 
-- because it will have to scan more entries in the index to find the relevant ones.
-- d) Why does the range size affect whether Oracle uses the index?
-- A: The range size affects whether Oracle uses the index because if the range is too large, it may be more efficient for
-- Oracle to perform a full table scan instead of using the index, especially if the index has low selectivity 
-- (i.e., many entries for each distinct value). If the range is small, it is more likely that using the index will be faster 
-- than scanning the entire table.


-- ============================================================
-- Exercise 3 — Composite index
--
-- You often query by both patient_id AND visit_date together:
--   WHERE patient_id = 1234 AND visit_date > SYSDATE - 90
--
-- Two options:
--   Option A: Two separate indexes (one per column)
--   Option B: One composite index (patient_id, visit_date)
--
-- Create the composite index and test the query.
-- ============================================================

-- Questions:
-- a) Does the plan use the composite index?
-- A: Yes, the plan uses the composite index when filtering by both patient_id and visit_date together
-- b) Now try querying ONLY on visit_date (no patient_id).
--    Does the composite index get used? Why not?
-- A: It does not get used because the composite index is ordered by patient_id first, and then visit_date. When querying only on visit_date,
-- the database cannot efficiently use the composite index because it is not filtering by the leading column.
-- c) What's the rule about column order in composite indexes?
-- A: The rule about column order in composite indexes is that the leading column(s) should be the one(s) that are most commonly used in filtering conditions.


-- ============================================================
-- Exercise 4 — Function that breaks an index
--
-- There IS an index on patient_id (from lesson 03).
-- Predict what happens when you wrap the column in a function.
-- ============================================================

-- This query CAN use the index:
SELECT * FROM patient_visits WHERE patient_id = 5432;
-- This one cannot — why?
SELECT * FROM patient_visits WHERE TO_CHAR(patient_id) = '5432';

-- Questions:
-- a) What scan type did the second query use?
-- A: The second query used a full table scan, because the function TO_CHAR(patient_id) prevents the database from using the index on patient_id.
-- b) Why does wrapping a column in a function break index use?
-- A: Indexes store the raw column values, not function results, so the database must compute the function for every single row to check for a match.
-- c) How would you rewrite the second query to allow index use?
-- A: Remove the function from the column: WHERE patient_id = 5432; (Always apply transformations to the input value, never the indexed column).



-- ============================================================
-- Exercise 5 — Discussion: real-world scenarios
--
-- For each scenario below, decide:
--   a) Would you add an index?
--   b) On which column(s)?
--   c) Any concerns?
-- ============================================================

-- Scenario A:
-- A reporting table gets loaded once per night (batch ETL).
-- During the day, analysts run SELECT queries by date range.
-- The table has 50 million rows.
-- → Index on date? Yes/No, why?

-- a) Yes
-- b) On the date column
-- c) The write penalty doesn't matter since data is batch-loaded at night, so not really

-- Scenario B:
-- An OLTP orders table gets 10,000 inserts per minute.
-- Support staff look up orders by customer_id or order_status.
-- order_status has 4 values: pending, processing, shipped, cancelled.
-- → What indexes would you add?

-- a) Yes
-- b) Only customer_id
-- c) order_status has low cardinality, so indexing would not be that effective, and the write penalty would be really heavy (100000 inserts per minute)

-- Scenario C:
-- A patient table has an email column (unique per patient).
-- There are 5 million patients.
-- The app frequently does: WHERE email = 'user@example.com'
-- → What kind of index would be best here?

-- a) Yes, a Unique B-tree index
-- b) email
-- c) This enforces business logic (no duplicates) and provides lightning-fast exact-match lookups. The write penalty
-- may be a concern, but it is acceptable given the previous stated benefits