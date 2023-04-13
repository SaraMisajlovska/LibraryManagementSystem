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
SELECT COUNT(DISTINCT job_title) FROM librarian
