-- Test connection
SELECT COUNT(*) AS task_count FROM tasks;

-- KPI 1: Tasks by Status
SELECT status,
       COUNT(*) AS task_count,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_of_total
FROM   tasks
GROUP  BY status
ORDER  BY task_count DESC;

-- KPI 2: Tasks per Team
SELECT t.name AS team_name,
       COUNT(ts.id) AS task_count
FROM   teams t
LEFT   JOIN users u ON u.team_id = t.id
LEFT   JOIN tasks ts ON ts.assigned_to = u.id
GROUP  BY t.id, t.name
ORDER  BY task_count DESC;

-- KPI 3: Workload per User (open + in_progress + blocked)
SELECT u.full_name,
       t.name AS team_name,
       COUNT(ts.id) AS open_tasks
FROM   users u
JOIN   teams t ON t.id = u.team_id
LEFT   JOIN tasks ts ON ts.assigned_to = u.id
                    AND ts.status IN ('open', 'in_progress', 'blocked')
GROUP  BY u.id, u.full_name, t.name
ORDER  BY open_tasks DESC;

-- KPI 4 & 5: Completion Rate + Avg Resolution Hours
SELECT ROUND(
           COUNT(CASE WHEN status = 'completed' THEN 1 END) * 100.0
           / NULLIF(COUNT(CASE WHEN status != 'cancelled' THEN 1 END), 0),
           1
       ) AS completion_rate_pct,
       ROUND(AVG(
           EXTRACT(DAY FROM (completed_at - created_at)) * 24 +
           EXTRACT(HOUR FROM (completed_at - created_at)) +
           EXTRACT(MINUTE FROM (completed_at - created_at)) / 60
       ), 1) AS avg_resolution_hours
FROM   tasks
WHERE  status = 'completed'
  AND  completed_at IS NOT NULL;

-- KPI 6: Tasks Created per Day
SELECT TRUNC(created_at) AS creation_date,
       COUNT(*) AS tasks_created
FROM   tasks
GROUP  BY TRUNC(created_at)
ORDER  BY creation_date;

-- KPI 7: Overdue Tasks
SELECT ts.title,
       ts.status,
       ts.priority,
       ts.due_date,
       u.full_name AS assignee,
       t.name AS team
FROM   tasks ts
LEFT   JOIN users u ON u.id = ts.assigned_to
LEFT   JOIN teams t ON t.id = u.team_id
WHERE  ts.due_date < TRUNC(SYSDATE)
  AND  ts.status NOT IN ('completed', 'cancelled')
  AND  ts.due_date IS NOT NULL
ORDER  BY ts.due_date;

-- KPI 8: Priority Distribution by Status
SELECT priority,
       COUNT(CASE WHEN status = 'open'        THEN 1 END) AS open_count,
       COUNT(CASE WHEN status = 'in_progress' THEN 1 END) AS in_progress_count,
       COUNT(CASE WHEN status = 'blocked'      THEN 1 END) AS blocked_count,
       COUNT(CASE WHEN status = 'completed'   THEN 1 END) AS completed_count
FROM   tasks
GROUP  BY priority
ORDER  BY CASE priority
              WHEN 'critical' THEN 1
              WHEN 'high'     THEN 2
              WHEN 'medium'   THEN 3
              WHEN 'low'      THEN 4
          END;

-- Exercise: Tasks Completed per Day
SELECT TRUNC(completed_at) AS completion_date,
       COUNT(*) AS tasks_completed
FROM   tasks
WHERE  status = 'completed'
  AND  completed_at IS NOT NULL
GROUP  BY TRUNC(completed_at)
ORDER  BY completion_date;
