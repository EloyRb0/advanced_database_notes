-- ============================================
-- EXERCISE 1: Explore your schema
-- ============================================

SELECT object_type, COUNT(*) AS cnt
FROM user_objects
GROUP BY object_type
ORDER BY object_type;

[
  {
    "object_type": "INDEX",
    "cnt": 4
  },
  {
    "object_type": "LOB",
    "cnt": 1
  },
  {
    "object_type": "SEQUENCE",
    "cnt": 2
  },
  {
    "object_type": "TABLE",
    "cnt": 5
  }
]

SELECT object_name, object_type, created, last_ddl_time
FROM user_objects
ORDER BY object_type, object_name;

[
  {
    "object_name": "IDX_PATIENT_VISITS_DATE",
    "object_type": "INDEX",
    "created": "2026-04-14T15:38:04Z",
    "last_ddl_time": "2026-04-14T15:38:04Z"
  },
  {
    "object_name": "SYS_C003238684",
    "object_type": "INDEX",
    "created": "2026-04-07T15:41:59Z",
    "last_ddl_time": "2026-04-07T15:41:59Z"
  },
  {
    "object_name": "SYS_C003459532",
    "object_type": "INDEX",
    "created": "2026-04-14T15:25:33Z",
    "last_ddl_time": "2026-04-14T15:25:33Z"
  },
  {
    "object_name": "SYS_IL0002936367C00004$$",
    "object_type": "INDEX",
    "created": "2026-04-07T15:41:59Z",
    "last_ddl_time": "2026-04-07T15:41:59Z"
  },
  {
    "object_name": "SYS_LOB0002936367C00004$$",
    "object_type": "LOB",
    "created": "2026-04-07T15:41:59Z",
    "last_ddl_time": "2026-04-07T15:41:59Z"
  },
  {
    "object_name": "ISEQ$$_2936367",
    "object_type": "SEQUENCE",
    "created": "2026-04-07T15:41:59Z",
    "last_ddl_time": "2026-04-07T15:41:59Z"
  },
  {
    "object_name": "ISEQ$$_3133196",
    "object_type": "SEQUENCE",
    "created": "2026-04-14T15:25:33Z",
    "last_ddl_time": "2026-04-14T15:25:33Z"
  },
  {
    "object_name": "BRICKS",
    "object_type": "TABLE",
    "created": "2026-03-03T15:05:22Z",
    "last_ddl_time": "2026-03-03T15:05:22Z"
  },
  {
    "object_name": "DOC_CHUNKS",
    "object_type": "TABLE",
    "created": "2026-04-07T15:41:59Z",
    "last_ddl_time": "2026-04-07T15:41:59Z"
  },
  {
    "object_name": "MY_BRICK_COLLECTION",
    "object_type": "TABLE",
    "created": "2026-03-10T14:23:31Z",
    "last_ddl_time": "2026-03-10T14:23:31Z"
  },
  {
    "object_name": "PATIENT_VISITS",
    "object_type": "TABLE",
    "created": "2026-04-14T15:25:33Z",
    "last_ddl_time": "2026-04-14T16:01:13Z"
  },
  {
    "object_name": "YOUR_BRICK_COLLECTION",
    "object_type": "TABLE",
    "created": "2026-03-10T14:23:31Z",
    "last_ddl_time": "2026-03-10T14:23:31Z"
  }
]

-- ============================================
-- EXERCISE 2: Basic GET_DDL
-- ============================================

[
  {
    "dbms_metadata.get_ddl('table','bricks')": "\n  CREATE TABLE \"A00227629_SCHEMA_7MC8H\".\"BRICKS\" \n   (\t\"BRICK_ID\" NUMBER(*,0), \n\t\"COLOUR\" VARCHAR2(10), \n\t\"SHAPE\" VARCHAR2(10), \n\t\"WEIGHT\" NUMBER(*,0)\n   ) SEGMENT CREATION IMMEDIATE \n  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 \n NOCOMPRESS LOGGING\n  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645\n  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1\n  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)\n  TABLESPACE \"USERS\" "
  }
]


-- ============================================
-- EXERCISE 3: Clean DDL for portability
-- ============================================


[
  {
    "dbms_metadata.get_ddl('table',table_name)": CREATE TABLE "BRICKS" 
   (    "BRICK_ID" NUMBER(*,0), 
        "COLOUR" VARCHAR2(10), 
        "SHAPE" VARCHAR2(10), 
        "WEIGHT" NUMBER(*,0)
   );
  }
]

-- ============================================
-- EXERCISE 4: Plan a migration
-- ============================================

SELECT constraint_name, table_name, r_constraint_name
FROM user_constraints
WHERE constraint_type = 'R' AND table_name = 'BRICKS';

-- It displays no items, there are no foreign key constraints in the table

-- CHECKLIST
BEGIN
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'EMIT_SCHEMA', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'TABLESPACE', false);
END;
/

[
  {
    "dbms_metadata.get_ddl('table',table_name)": CREATE TABLE "BRICKS" 
   (    "BRICK_ID" NUMBER(*,0), 
        "COLOUR" VARCHAR2(10), 
        "SHAPE" VARCHAR2(10), 
        "WEIGHT" NUMBER(*,0)
   );
  }
]

-- ============================================
-- EXERCISE 5: Dependency order
-- ============================================

SELECT referencing_name, referencing_type
FROM user_dependencies
WHERE referenced_name = 'BRICKS'
ORDER BY referencing_type, referencing_name;

-- No rows selected. (There are currently no procedures, functions, or views depending on the BRICKS table).


-- ============================================
-- EXERCISE 6: Design your own backup strategy
-- ============================================

-- STEP 1: Document your current schema structure
SELECT table_name, num_rows FROM user_tables ORDER BY num_rows DESC;

[
  {
    "table_name": "PATIENT_VISITS",
    "num_rows": 15
  },
  {
    "table_name": "BRICKS",
    "num_rows": 3
  },
  {
    "table_name": "DOC_CHUNKS",
    "num_rows": 0
  },
  {
    "table_name": "MY_BRICK_COLLECTION",
    "num_rows": 0
  },
  {
    "table_name": "YOUR_BRICK_COLLECTION",
    "num_rows": 0
  }
]

-- STEP 2: Extract all DDL (Assuming parameters are already set from Ex 4)
SELECT DBMS_METADATA.GET_DDL('TABLE', table_name) FROM user_tables;
SELECT DBMS_METADATA.GET_DDL('INDEX', index_name) FROM user_indexes;
SELECT DBMS_METADATA.GET_DDL('SEQUENCE', sequence_name) FROM user_sequences;
-- (Spool these outputs to separate files for safe keeping)

-- STEP 3: Reload in new schema (use proper order)
-- 1. Create tables (BRICKS, DOC_CHUNKS, PATIENT_VISITS, etc.)
-- 2. Create sequences (ISEQ$$_2936367, ISEQ$$_3133196)
-- 3. Create indexes (IDX_PATIENT_VISITS_DATE, plus system-generated ones)
-- 4. Add constraints (enable FKs - none currently exist for BRICKS)
-- 5. Create views (none)
-- 6. Create procedures/functions/packages (none)

-- STEP 4: Verify everything transferred
SELECT object_type, COUNT(*) FROM user_objects GROUP BY object_type;
-- Expected Output: Should exactly match the JSON from Exercise 1

SELECT index_name, table_name FROM user_indexes ORDER BY index_name;

[
  {
    "index_name": "IDX_PATIENT_VISITS_DATE",
    "table_name": "PATIENT_VISITS"
  },
  {
    "index_name": "SYS_C003238684",
    "table_name": "DOC_CHUNKS"
  },
  {
    "index_name": "SYS_C003459532",
    "table_name": "PATIENT_VISITS"
  },
  {
    "index_name": "SYS_IL0002936367C00004$$",
    "table_name": "DOC_CHUNKS"
  }
]


-- ============================================
-- DISCUSSION QUESTIONS
-- ============================================
-- Q1: What are the limitations of DBMS_METADATA vs expdp?
-- A:  DBMS_METADATA only exports DDL (no data), requires manual spool/cursor,
--     and can't handle very large schemas easily.
--     expdp is faster, can export data, handles large schemas, but needs directory access.
--     Choose DBMS_METADATA when you have no DBA access or need educational visibility.
--     Choose expdp when you have proper access and need speed/completeness.

-- Q2: If you have circular dependencies (A depends on B, B depends on A),
--     how would you handle the reload?
-- A:  Oracle handles most circular dependencies automatically if you create
--     objects first and enable constraints later.
--     For PL/SQL circular dependencies, create the package/spec first,
--     then the package/body second.
--     DBMS_METADATA returns objects in a valid order - trust the dependency analysis.

-- Q3: Your company is migrating from one Oracle database to another.
--     They give you read-only access to the old database and want you
--     to recreate the schema on the new database.
--     What's your plan?
-- A:  1. Document source schema structure (user_objects, user_tables, etc.)
--     2. Set EMIT_SCHEMA=false and extract clean DDL
--     3. Check for dependencies and schema-qualified references
--     4. Review and clean up the DDL (remove storage, fix schema names)
--     5. Create new schema user on target
--     6. Run DDL in proper order (tables -> constraints -> indexes -> views -> code)
--     7. Verify with object counts and sample queries
--     8. If possible, export sample data via INSERT statements or CSV
