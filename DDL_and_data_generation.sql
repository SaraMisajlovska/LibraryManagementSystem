-- Create membership table
CREATE TABLE membership
(
    id      SERIAL PRIMARY KEY,
    price   NUMERIC(10, 2) NOT NULL,
    package VARCHAR(255)   NOT NULL CHECK (package IN ('STUDENT', 'STANDARD', 'SENIOR'))
);

-- Create User table
CREATE TABLE library_user
(
    id            SERIAL PRIMARY KEY,
    email         VARCHAR(255) UNIQUE NOT NULL,
    user_password VARCHAR(255)        NOT NULL,
    first_name    VARCHAR(255)        NOT NULL,
    last_name     VARCHAR(255)        NOT NULL,
    date_of_birth DATE                NOT NULL,
    address       TEXT                NOT NULL,
    phone_number  VARCHAR(20)         NOT NULL CHECK (phone_number ~ '^[0-9]{10}$'),
    CONSTRAINT CK_user_password CHECK (char_length(user_password) >= 8)
);

-- Create the patron table that inherits from user
CREATE TABLE patron
(
    card_number   INTEGER UNIQUE NOT NULL,
    membership_id INTEGER        NOT NULL REFERENCES membership (id),
    id            SERIAL PRIMARY KEY
) INHERITS (library_user);

-- Create the librarian table that inherits from user
CREATE TABLE librarian
(
    job_title VARCHAR(255) NOT NULL,
    hire_date DATE         NOT NULL,
    id        SERIAL PRIMARY KEY
) INHERITS (library_user);

-- Create category table
CREATE TABLE category
(
    id            SERIAL PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL CHECK ( category_name IN ('ADVENTURE',
                                                                  'BIOGRAPHY',
                                                                  'CHILDREN',
                                                                  'DRAMA',
                                                                  'EDUCATION',
                                                                  'FANTASY',
                                                                  'HISTORY',
                                                                  'HORROR',
                                                                  'MANGA',
                                                                  'MYSTERY',
                                                                  'POETRY',
                                                                  'ROMANCE',
                                                                  'SCIENCE_FICTION',
                                                                  'SELF_HELP',
                                                                  'THRILLER',
                                                                  'TRAVEL'))
);

-- Create publisher table
CREATE TABLE publisher
(
    id                SERIAL PRIMARY KEY,
    publisher_name    VARCHAR(255) NOT NULL,
    publisher_address VARCHAR(255) NOT NULL,
    contact           VARCHAR(255) NOT NULL
);

-- Create author table
CREATE TABLE author
(
    id          SERIAL PRIMARY KEY,
    author_name VARCHAR(255) NOT NULL,
    birth_date  DATE         NOT NULL,
    biography   TEXT         NULL
);

-- Create book_request table
CREATE TABLE book_request
(
    id         SERIAL PRIMARY KEY,
    user_id    INTEGER DEFAULT 0 NOT NULL REFERENCES patron (id) ON DELETE SET DEFAULT,
    book_title VARCHAR(255)      NOT NULL,
    author     VARCHAR(255)      NOT NULL
);

-- Create book table
CREATE TABLE book
(
    id               SERIAL PRIMARY KEY,
    title            VARCHAR(255) NOT NULL,
    publisher_id     INTEGER      NOT NULL REFERENCES publisher (id),
    publication_date DATE         NOT NULL,
    summary          TEXT         NOT NULL,
    book_request_id  INTEGER      NULL REFERENCES book_request (id)
);

-- Create payment table
CREATE TABLE payment
(
    id             SERIAL PRIMARY KEY,
    payment_date   DATE              NOT NULL,
    membership_id  INTEGER           NOT NULL REFERENCES membership (id),
    payment_method VARCHAR(255)      NOT NULL CHECK (payment_method IN ('CASH', 'CARD')),
    user_id        INTEGER DEFAULT 0 NOT NULL REFERENCES patron (id) ON DELETE SET DEFAULT
);

-- Create book_location table
CREATE TABLE book_location
(
    id      SERIAL PRIMARY KEY,
    section VARCHAR(50) NOT NULL,
    shelf   INTEGER     NOT NULL
);

-- Create book_copy table
CREATE TABLE book_copy
(
    id          SERIAL PRIMARY KEY,
    book_id     INTEGER      NOT NULL REFERENCES book (id),
    location_id INTEGER      NOT NULL REFERENCES book_location (id),
    edition     INTEGER      NOT NULL,
    book_format VARCHAR(255) NOT NULL CHECK ( book_format IN ('PAPERBACK', 'HARDCOVER'))
);

-- Create book_author table
CREATE TABLE book_author
(
    book_id   INTEGER NOT NULL REFERENCES book (id),
    author_id INTEGER NOT NULL REFERENCES author (id),
    PRIMARY KEY (book_id, author_id)
);

-- Create book_category table
CREATE TABLE book_category
(
    book_id     INTEGER NOT NULL REFERENCES book (id),
    category_id INTEGER NOT NULL REFERENCES category (id),
    PRIMARY KEY (book_id, category_id)
);

-- Create book_review table
CREATE TABLE book_review
(
    id      SERIAL PRIMARY KEY,
    user_id INTEGER DEFAULT 0 NOT NULL REFERENCES patron (id) ON DELETE SET DEFAULT,
    book_id INTEGER           NOT NULL REFERENCES book (id),
    review  TEXT              NOT NULL
);

-- Create book_rating table
CREATE TABLE book_rating
(
    id      SERIAL PRIMARY KEY,
    user_id INTEGER DEFAULT 0 NOT NULL REFERENCES patron (id) ON DELETE SET DEFAULT,
    book_id INTEGER           NOT NULL REFERENCES book (id),
    rating  INTEGER           NOT NULL
);

-- Create reading_list table
CREATE TABLE reading_list
(
    user_id INTEGER DEFAULT 0 NOT NULL REFERENCES patron (id) ON DELETE SET DEFAULT,
    book_id INTEGER           NOT NULL REFERENCES book (id),
    PRIMARY KEY (user_id, book_id)
);

CREATE TABLE book_borrow
(
    id                    SERIAL PRIMARY KEY,
    user_id               INTEGER DEFAULT 0 NOT NULL REFERENCES patron (id) ON DELETE SET DEFAULT,
    book_copy_id          INTEGER           NOT NULL REFERENCES book_copy (id),
    book_checkout         DATE              NOT NULL,
    book_return           DATE              NULL,
    damage                VARCHAR(255)      NULL,
    checkout_librarian_id INTEGER DEFAULT 0 NOT NULL REFERENCES librarian (id) ON DELETE SET DEFAULT,
    return_librarian_id   INTEGER DEFAULT 0 NOT NULL REFERENCES librarian (id) ON DELETE SET DEFAULT
);

CREATE TABLE book_reservation
(
    id                 SERIAL PRIMARY KEY,
    book_copy_id       INTEGER           NOT NULL REFERENCES book_copy (id),
    user_id            INTEGER DEFAULT 0 NOT NULL REFERENCES patron (id) ON DELETE SET DEFAULT,
    reservation_status VARCHAR(255)      NOT NUll CHECK (reservation_status IN ('ACTIVE', 'CANCELLED', 'EXPIRED', 'CHECKED_OUT')),
    reservation_date   DATE              NOT NULL CHECK (reservation_date >= CURRENT_DATE)
);

CREATE TABLE library_event
(
    id             SERIAL PRIMARY KEY,
    event_name     VARCHAR(255) NOT NULL,
    description    TEXT         NOT NULL,
    event_datetime TIMESTAMP    NOT NULL CHECK (event_datetime >= CURRENT_TIMESTAMP)
);

CREATE TABLE event_users
(
    id        SERIAL PRIMARY KEY,
    event_id  INTEGER           NOT NULL REFERENCES library_event (id) ON DELETE SET DEFAULT,
    user_id   INTEGER DEFAULT 0 NOT NULL REFERENCES library_user (id) ON DELETE SET DEFAULT,
    user_type VARCHAR(255)      NOT NULL CHECK ( user_type IN ('PATRON', 'LIBRARIAN'))
);

--End of DDL

--import default values
INSERT INTO membership(id, price, package)
VALUES (0, 0.00, 'NONE');

-- Insert unknown user used for default value on referential constraints
INSERT INTO library_user(id, email, user_password, first_name, last_name, date_of_birth, address, phone_number)
SELECT 0,
       'unknown',
       'password',
       'unknown',
       'unknown',
       NOW(),
       'unknown',
       '0000000000';

-- Insert unknown user used for default value on referential constraints
INSERT INTO patron
(id, email, user_password, first_name, last_name, date_of_birth, address, phone_number, card_number, membership_id)
SELECT -1,
       'unknown_patron',
       'password',
       'unknown',
       'unknown',
       NOW(),
       'unknown',
       '0000000000',
       -1,
       0;

-- Insert unknown user used for default value on referential constraints
INSERT INTO librarian(id, email, user_password, first_name, last_name, date_of_birth, address, phone_number, job_title,
                      hire_date)
SELECT -2,
       'unknown_librarian',
       'password',
       'unknown',
       'unknown',
       NOW(),
       'unknown',
       '0000000000',
       'unknown',
       NOW();

INSERT INTO publisher(id, publisher_name, publisher_address, contact)
VALUES (0, 'unknown', 'unknown', 'unknown');


INSERT INTO author(id, author_name, birth_date)
VALUES (0, 'unknown', NOW());


INSERT INTO book(id, title, publisher_id, publication_date, summary)
VALUES (0, 'unknown', 0, NOW(), 'unknown');

INSERT INTO book_location(id, section, shelf)
VALUES (0, 'unknown', -1);

INSERT INTO book_copy(id, book_id, location_id, edition, book_format)
VALUES (0, 0, 0, 0, 'UNKNOWN');


-- insert statement for memberships
INSERT INTO membership (price, package)
VALUES (150.0, 'STUDENT'),
       (200.0, 'STANDARD'),
       (300.0, 'SENIOR');

--import library_users.csv

--sequence that creates a patron card number and make it default for the patron's card_number
CREATE SEQUENCE IF NOT EXISTS card_number_seq
    increment 3
    start 100005;
ALTER TABLE patron ALTER COLUMN card_number SET DEFAULT nextval('card_number_seq');

-- insert statement that creates a patron from library_user
INSERT INTO patron (email, user_password, first_name, last_name, date_of_birth, address, phone_number,
                    membership_id)
SELECT u.email,
       u.user_password,
       u.first_name,
       u.last_name,
       u.date_of_birth,
       u.address,
       u.phone_number,
       (floor(random() * (3 - 1 + 1) + 1)::int)
FROM library_user u;

-- function that picks a random job title for each entry
CREATE OR REPLACE FUNCTION random_job_title()
    RETURNS varchar
    LANGUAGE sql
    VOLATILE PARALLEL SAFE AS
$func$
SELECT ('[0:15]={ ''Library Director'',
                         ''Cataloging and Metadata Librarian'',
                         ''Reference Librarian'',
                         ''Information Literacy Librarian'',
                         ''Archivist'',
                         ''Special Collections Librarian'',
                         ''Digital Services Librarian'',
                         ''Youth Services Librarian'',
                         ''School Librarian'',
                         ''Technical Services Librarian'',
                         ''Circulation Librarian'',
                         ''Acquisitions Librarian'',
                         ''Research and Instruction Librarian'',
                         ''Rare Books and Manuscripts Librarian'',
                         ''Cataloger'',
                         ''Media Librarian''}'::varchar[])[trunc(random() * 16)::int];
$func$;

-- insert statement that creates a patron from library_user
INSERT INTO librarian (email, user_password, first_name, last_name, date_of_birth, address, phone_number,
                       job_title, hire_date)
SELECT u.email,
       u.user_password,
       u.first_name,
       u.last_name,
       u.date_of_birth,
       u.address,
       u.phone_number,
       random_job_title()                                                   AS job_title,
       (SELECT NOW() - INTERVAL '1 day' - (random() * INTERVAL '10 years')) AS hire_date
FROM library_user u;

--create temp table with only 30 librarians
CREATE TABLE librarians_to_keep
AS
SELECT *
FROM librarian
         TABLESAMPLE BERNOULLI (1);

--empty the original librarians table
TRUNCATE TABLE librarian CASCADE ;

--add back the librarians that we kept
insert into librarian
select *
from librarians_to_keep;

--drop the helper table
DROP TABLE librarians_to_keep ;

--check to see how many different job titles we have in the final librarian table
SELECT COUNT(DISTINCT job_title) FROM librarian;

--import category.csv
--import publisher.csv
--import author.csv
--import book_request.csv
--import book.csv

--insert payments
CREATE OR REPLACE FUNCTION random_payment_date()
RETURNS TIMESTAMP
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN NOW() - INTERVAL '1 day' - (random() * INTERVAL '10 years');
END $$;

INSERT INTO payment (payment_date, membership_id, payment_method, user_id)
SELECT random_payment_date() AS payment_date,
       (floor(random() * (3 - 1 + 1) + 1)::int)                             as membership_id,
       CASE WHEN random() < 0.4 THEN 'CASH' ELSE 'CARD' END                 AS payment_method,
       patron.id                                                            as user_id
FROM patron
CROSS JOIN generate_series(1,600);

--import book_location.csv
--import book_copy.csv

--insert in book_author
INSERT INTO book_author(book_id, author_id)
SELECT book.id, author.id FROM book NATURAL JOIN author;

--import book_category.csv
--import book_review.csv
--import book_rating.csv
--import reading_list.csv
--import book_borrow.csv

--insert in book_borrow

insert into book_borrow(user_id, book_copy_id, checkout_librarian_id, book_checkout)
SELECT patron_copy.id,
       book_copy.id,
       librarian_copy.id,
       now() - interval '1000 days' * random()
FROM (

SELECT id, ROW_NUMBER() OVER () AS row_num
      FROM generate_series(1, 1) s(i)
               CROSS JOIN LATERAL (
          SELECT id FROM book_copy ORDER BY random()
          ) AS book


      limit 30000) AS book_copy


         CROSS JOIN (SELECT id, ROW_NUMBER() OVER () AS row_num
                     FROM generate_series(1, 3) s(i)
                              CROSS JOIN LATERAL (
                         SELECT id FROM patron where id != -1 ORDER BY random()
                         ) AS patron) AS patron_copy


         CROSS JOIN (SELECT id, ROW_NUMBER() OVER () AS row_num
                     FROM generate_series(1, 10) s(i)
                              CROSS JOIN LATERAL (
                         SELECT id FROM librarian where id != -2 ORDER BY random()
                         ) AS librarian) AS librarian_copy
ORDER BY random();

--import book_reservation.csv
--import library_event.csv

--insert in event_users
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
