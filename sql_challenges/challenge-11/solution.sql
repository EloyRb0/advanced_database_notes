-- ============================================================
-- Lesson 03: SQLAlchemy ORM + Alembic Migrations
-- File: solution.sql
-- Purpose: SQL answers for all 5 lesson exercises
-- Dialect: Oracle 23ai (FreeSQL)
-- ============================================================

-- ============================================================
-- BASE SCHEMA (provided — run first for a clean environment)
-- ============================================================

DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS tasks;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS teams;

CREATE TABLE teams (
    id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        VARCHAR2(50)  NOT NULL UNIQUE,
    description VARCHAR2(200),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username    VARCHAR2(50)  NOT NULL UNIQUE,
    email       VARCHAR2(100) NOT NULL,
    full_name   VARCHAR2(100),
    team_id     NUMBER,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_team FOREIGN KEY (team_id) REFERENCES teams(id)
);

CREATE TABLE tasks (
    id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title       VARCHAR2(200) NOT NULL,
    description VARCHAR2(1000),
    status      VARCHAR2(20)  DEFAULT 'open',
    assigned_to NUMBER,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP,
    CONSTRAINT fk_tasks_user FOREIGN KEY (assigned_to) REFERENCES users(id)
);

-- Seed data
INSERT INTO teams (name, description) VALUES ('Engineering', 'Software development team');
INSERT INTO teams (name, description) VALUES ('Product', 'Product management team');

INSERT INTO users (username, email, full_name, team_id)
    VALUES ('alice_dev', 'alice@example.com', 'Alice Smith', 1);
INSERT INTO users (username, email, full_name, team_id)
    VALUES ('bob_dev', 'bob@example.com', 'Bob Jones', 1);
INSERT INTO users (username, email, full_name, team_id)
    VALUES ('carol_pm', 'carol@example.com', 'Carol White', 2);

INSERT INTO tasks (title, description, status, assigned_to)
    VALUES ('Fix login bug', 'Users cannot log in with SSO', 'open', 1);
INSERT INTO tasks (title, description, status, assigned_to)
    VALUES ('Design new dashboard', 'Create mockups for analytics page', 'in_progress', 3);
INSERT INTO tasks (title, description, status, assigned_to)
    VALUES ('Update dependencies', 'Upgrade numpy and pandas', 'open', 2);

COMMIT;


-- ============================================================
-- EXERCISE 1 — Model Design: Comments Table
-- ============================================================
-- Each comment belongs to one task and one user.
-- Deleting a task cascades and removes all its comments.

CREATE TABLE comments (
    id         NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id    NUMBER        NOT NULL,
    user_id    NUMBER        NOT NULL,
    content    VARCHAR2(2000) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_comments_task
        FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,

    CONSTRAINT fk_comments_user
        FOREIGN KEY (user_id) REFERENCES users(id),

    -- Bonus: content must not be an empty string
    CONSTRAINT ck_comments_content
        CHECK (TRIM(content) IS NOT NULL AND LENGTH(TRIM(content)) > 0)
);

-- Verify structure
SELECT column_name, data_type, nullable
FROM   user_tab_columns
WHERE  table_name = 'COMMENTS'
ORDER BY column_id;

-- Questions answered (as comments):
-- 1. Comment relates to Task (many-to-one) and User (many-to-one).
-- 2. Task should expose a back-reference so task.comments navigates to its list.
-- 3. ON DELETE CASCADE means dropping a task also deletes all its comments.


-- ============================================================
-- EXERCISE 2 — Migration Creation (Alembic upgrade/downgrade DDL)
-- ============================================================
-- Alembic's upgrade() would execute the CREATE TABLE above.
-- Alembic's downgrade() would execute the DROP below.

-- upgrade() equivalent:
--   CREATE TABLE comments ( ... )   ← already run in Exercise 1

-- downgrade() equivalent:
DROP TABLE comments;

-- Re-create after demonstrating the downgrade:
CREATE TABLE comments (
    id         NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id    NUMBER        NOT NULL,
    user_id    NUMBER        NOT NULL,
    content    VARCHAR2(2000) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comments_task
        FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    CONSTRAINT fk_comments_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT ck_comments_content
        CHECK (TRIM(content) IS NOT NULL AND LENGTH(TRIM(content)) > 0)
);
COMMIT;

-- Questions answered:
-- 1. upgrade() creates the comments table in the live database.
-- 2. downgrade() drops it, reverting to the previous schema version.
-- 3. Downgrading this migration permanently destroys all comment rows.


-- ============================================================
-- EXERCISE 3 — CRUD Challenge
-- ============================================================

-- 1. Create the DevOps team
INSERT INTO teams (name, description)
    VALUES ('DevOps', 'DevOps and infrastructure team');

-- 2. Create diana_ops linked to the new team
INSERT INTO users (username, email, full_name, team_id)
    VALUES ('diana_ops', 'diana@example.com', 'Diana Ops',
            (SELECT id FROM teams WHERE name = 'DevOps'));

-- 3. Create 3 tasks with different priorities (encoded in description)
INSERT INTO tasks (title, description, status, assigned_to)
    VALUES ('Set up CI/CD pipeline',
            '[priority:high] Configure GitHub Actions for automated deployments',
            'open',
            (SELECT id FROM users WHERE username = 'diana_ops'));

INSERT INTO tasks (title, description, status, assigned_to)
    VALUES ('Monitor server health',
            '[priority:medium] Install and configure Prometheus + Grafana',
            'open',
            (SELECT id FROM users WHERE username = 'diana_ops'));

INSERT INTO tasks (title, description, status, assigned_to)
    VALUES ('Update SSL certificates',
            '[priority:low] Renew expiring certs on staging servers',
            'open',
            (SELECT id FROM users WHERE username = 'diana_ops'));

-- 4. Print task count
SELECT COUNT(*) AS total_tasks FROM tasks;

-- 5. Close the highest-priority task
UPDATE tasks
SET    status     = 'closed',
       updated_at = CURRENT_TIMESTAMP
WHERE  title = 'Set up CI/CD pipeline';

-- 6. Delete the lowest-priority task
DELETE FROM tasks
WHERE  title = 'Update SSL certificates';

COMMIT;

-- Verify remaining tasks for diana_ops
SELECT t.title, t.status, u.full_name AS assignee
FROM   tasks t
JOIN   users u ON u.id = t.assigned_to
WHERE  u.username = 'diana_ops';


-- ============================================================
-- EXERCISE 4 — Migration Rollback
-- ============================================================

-- Apply the bad migration (upgrade): add estimated_hours
ALTER TABLE tasks ADD estimated_hours NUMBER;

-- Verify the column exists
SELECT column_name FROM user_tab_columns
WHERE  table_name = 'TASKS' AND column_name = 'ESTIMATED_HOURS';

-- Rollback (downgrade -1): remove estimated_hours
ALTER TABLE tasks DROP COLUMN estimated_hours;

COMMIT;

-- Questions answered:
-- 1. After downgrade the estimated_hours column no longer exists in tasks.
-- 2. Any data stored in that column is permanently deleted — Oracle drops
--    column data with no automatic recovery.


-- ============================================================
-- EXERCISE 5 — Concept Check (answers as comments)
-- ============================================================

-- 1. Why use ORM instead of raw SQL?
--    ORM maps rows to Python objects so you work with attributes and methods
--    instead of raw SQL strings. Relationships (task.assignee) are navigated
--    automatically, the code is database-agnostic, and type safety catches
--    many bugs before they reach the database.

-- 2. Why use migrations?
--    Migrations version-control schema changes. Every ALTER/CREATE is stored
--    as an ordered, reversible file — teammates can reproduce the exact schema
--    on any environment and the history of changes is auditable.

-- 3. When would you rollback?
--    When a deployed migration breaks the application, introduces corrupt data,
--    or needs to be revised before re-applying. Rolling back returns the schema
--    to the last stable state while the fix is prepared.

-- 4. Difference between add() and commit()?
--    session.add(obj) stages the object in SQLAlchemy's unit-of-work — no SQL
--    is sent yet. session.commit() flushes all staged changes to the database
--    as a single transaction and makes them durable. Without commit() the
--    changes exist only in memory.

-- 5. Why are relationships useful?
--    They let you navigate between related objects with attribute access
--    (task.assignee, team.users) instead of writing JOIN queries manually.
--    SQLAlchemy generates the correct SQL automatically, and cascade settings
--    (delete-orphan) manage dependent rows without extra code.

-- ============================================================
-- END OF solution.sql
-- ============================================================
