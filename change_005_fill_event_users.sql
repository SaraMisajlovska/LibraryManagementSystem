INSERT INTO event_users (event_id, user_id, user_type)
SELECT e.id                                                        AS event_id,
       u.id                                                        AS user_id,
       CASE WHEN random() < 0.2 THEN 'LIBRARIAN' ELSE 'PATRON' END AS user_type
FROM library_event e
         CROSS JOIN LATERAL (
    SELECT id,
           user_password
    FROM library_user
    where id < 50
    ORDER BY random()
    LIMIT 50
    ) AS u
WHERE e.id < 100;

INSERT INTO event_users (event_id, user_id, user_type)
SELECT e.id                                                        AS event_id,
       u.id                                                        AS user_id,
       CASE WHEN random() < 0.2 THEN 'LIBRARIAN' ELSE 'PATRON' END AS user_type
FROM library_event e
         CROSS JOIN LATERAL (
    SELECT id,
           user_password
    FROM library_user
    where id > 50
      and id < 150
    ORDER BY random()
    LIMIT 50
    ) AS u
WHERE e.id >= 100
  AND e.id < 500;

INSERT INTO event_users (event_id, user_id, user_type)
SELECT e.id                                                        AS event_id,
       u.id                                                        AS user_id,
       CASE WHEN random() < 0.2 THEN 'LIBRARIAN' ELSE 'PATRON' END AS user_type
FROM library_event e
         CROSS JOIN LATERAL (
    SELECT id,
           user_password
    FROM library_user
    where id >= 150
      and id < 1000
    ORDER BY random()
    LIMIT 50
    ) AS u
WHERE e.id >= 500
  AND e.id < 1000;

INSERT INTO event_users (event_id, user_id, user_type)
SELECT e.id                                                        AS event_id,
       u.id                                                        AS user_id,
       CASE WHEN random() < 0.2 THEN 'LIBRARIAN' ELSE 'PATRON' END AS user_type
FROM library_event e
         CROSS JOIN LATERAL (
    SELECT id,
           user_password
    FROM library_user
    where id >= 1000
      and id < 2000
    ORDER BY random()
    LIMIT 50
    ) AS u
WHERE e.id >= 600
  AND e.id < 1100;

INSERT INTO event_users (event_id, user_id, user_type)
SELECT e.id                                                        AS event_id,
       u.id                                                        AS user_id,
       CASE WHEN random() < 0.2 THEN 'LIBRARIAN' ELSE 'PATRON' END AS user_type
FROM library_event e
         CROSS JOIN LATERAL (
    SELECT id,
           user_password
    FROM library_user
    where id > 1000
      and id < 2000
    ORDER BY random()
    LIMIT 50
    ) AS u
WHERE e.id >= 1100
  AND e.id < 1200;

INSERT INTO event_users (event_id, user_id, user_type)
SELECT e.id                                                        AS event_id,
       u.id                                                        AS user_id,
       CASE WHEN random() < 0.2 THEN 'LIBRARIAN' ELSE 'PATRON' END AS user_type
FROM library_event e
         CROSS JOIN LATERAL (
    SELECT id,
           user_password
    FROM library_user
    where id > 100
      and id < 2000
    ORDER BY random()
    LIMIT 50
    ) AS u
WHERE e.id >= 1200
  AND e.id < 3000;

INSERT INTO event_users (event_id, user_id, user_type)
SELECT e.id                                                        AS event_id,
       u.id                                                        AS user_id,
       CASE WHEN random() < 0.2 THEN 'LIBRARIAN' ELSE 'PATRON' END AS user_type
FROM library_event e
         CROSS JOIN LATERAL (
    SELECT id,
           user_password
    FROM library_user
    where id > 100
      and id < 1500
    ORDER BY random()
    LIMIT 50
    ) AS u
WHERE e.id >= 3000
  AND e.id < 4000;

INSERT INTO event_users (event_id, user_id, user_type)
SELECT e.id                                                        AS event_id,
       u.id                                                        AS user_id,
       CASE WHEN random() < 0.2 THEN 'LIBRARIAN' ELSE 'PATRON' END AS user_type
FROM library_event e
         CROSS JOIN LATERAL (
    SELECT id,
           user_password
    FROM library_user
    where id > 100
      and id < 1000
    ORDER BY random()
    LIMIT 50
    ) AS u
WHERE e.id >= 4000
  AND e.id < 4600