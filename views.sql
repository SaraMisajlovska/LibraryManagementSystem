-- view 1

CREATE VIEW book_search_view AS
SELECT b.title, a.author_name, c.category_name, b.publication_date
FROM book b
         LEFT JOIN book_author ba ON b.id = ba.book_id
         LEFT JOIN author a ON ba.author_id = a.id
         LEFT JOIN book_category bc ON b.id = bc.book_id
         LEFT JOIN category c ON bc.category_id = c.id;

-- view 3
CREATE VIEW all_reservations_view AS
SELECT p.first_name                    AS patron_first_name,
       p.last_name                     AS patron_last_name,
       p.card_number                   AS patron_card_number,
       b.title                         AS book_title,
       string_agg(a.author_name, ', ') AS book_author,
       c.category_name                 AS book_category,
       r.reservation_date              AS reservation_date,
       r.reservation_status            AS reservation_status
FROM book_reservation_new r
         JOIN book_copy bc ON bc.id = r.book_copy_id
         JOIN book b ON b.id = bc.book_id
         JOIN book_category bcg ON bcg.book_id = b.id
         JOIN category c ON c.id = bcg.category_id
         JOIN book_author ba ON ba.book_id = b.id
         JOIN author a ON a.id = ba.author_id
         LEFT JOIN patron p ON p.id = r.user_id
GROUP BY p.first_name, p.last_name, p.card_number, r.id, b.title, c.category_name, r.reservation_date,
         r.reservation_status, bc.edition;

-- view 4
CREATE VIEW user_active_reservations_view AS
SELECT p.first_name,
       p.last_name,
       p.card_number,
       b.title                           AS book_title,
       string_agg(a.author_name, ', ')   AS book_author,
       string_agg(c.category_name, ', ') AS book_category,
       br.reservation_date
FROM book_reservation_new br
         JOIN patron p ON p.id = br.user_id
         JOIN book_copy bc ON bc.id = br.book_copy_id
         JOIN book b ON b.id = bc.book_id
         JOIN book_author ba ON ba.book_id = b.id
         JOIN author a ON a.id = ba.author_id
         JOIN book_category bcg ON bcg.book_id = b.id
         JOIN category c ON c.id = bcg.category_id
WHERE br.reservation_status = 'ACTIVE'
GROUP BY p.first_name, p.last_name, p.card_number, b.id, br.reservation_date;

-- view 9
CREATE VIEW unreturned_books AS
SELECT p.first_name,
       p.last_name,
       p.card_number,
       b.title,
       string_agg(a.author_name, ', ')                                                          AS authors,
       bb.book_checkout,
       extract(days FROM date_trunc('day', CURRENT_DATE) - date_trunc('day', bb.book_checkout)) AS days_borrowed
FROM patron p
         JOIN book_borrow bb ON p.id = bb.user_id
         JOIN book_copy bc ON bb.book_copy_id = bc.id
         JOIN book b ON bc.book_id = b.id
         JOIN book_author ba ON b.id = ba.book_id
         JOIN author a ON ba.author_id = a.id
WHERE bb.book_return IS NULL
GROUP BY p.first_name, p.last_name, p.card_number, b.title, bb.book_checkout
ORDER BY bb.book_checkout;

-- view 10
CREATE VIEW user_info_view AS
SELECT u.first_name,
       u.last_name,
       u.date_of_birth,
       u.address,
       u.phone_number,
       p.card_number,
       m.package AS membership_package,
       CASE
           WHEN
               AGE(now(), MAX(pt.payment_date)) <= INTERVAL '1 year' THEN 'ACTIVE'
           ELSE 'EXPIRED'
           END
FROM library_user u
         LEFT JOIN payment pt ON u.id = pt.user_id
          JOIN patron p ON u.id = p.id
          JOIN membership m ON p.membership_id = m.id
GROUP BY u.id, u.first_name, u.last_name, u.date_of_birth, u.address, u.phone_number, p.card_number, m.package;


--view 2 - browse events
CREATE VIEW event_attendance AS
SELECT e.id as event_id, e.event_name, e.description, e.event_datetime, COUNT(DISTINCT eu.user_id) as num_attendees
FROM library_event e
         JOIN event_users eu ON eu.event_id = e.id
GROUP BY e.id, e.event_name, e.description, e.event_datetime;



--view 12 show reading list
CREATE  VIEW view_reading_list AS
SELECT patron.card_number, book.title, book.publisher_id, book.publication_date, book.summary
FROM reading_list
         JOIN patron ON reading_list.user_id = patron.id
         JOIN book ON reading_list.book_id = book.id;


--view 7 check user profile
CREATE VIEW user_profile AS
SELECT u.first_name,
       u.last_name,
       u.date_of_birth,
       u.address,
       u.phone_number,
       p.card_number,
       m.package
FROM library_user u
         JOIN patron p ON u.id = p.id
         JOIN membership m ON p.membership_id = m.id;


--view 8 check all users
CREATE VIEW librarian_users AS
SELECT id, first_name, last_name, email, phone_number
FROM library_user;


--view 5 Check book details, author, publisher, rating, review, and availability for book (user view)
CREATE VIEW book_details AS
SELECT b.id              AS book_id,
       b.title           AS book_title,
       p.publisher_name,
       a.author_name,
       bc.edition,
       bc.book_format,
       bc.location_id,
       br.rating,
       rv.review,
       CASE WHEN bb.id IS NULL THEN 'Available' ELSE 'Borrowed' END AS availability
FROM book AS b
         JOIN publisher AS p ON b.publisher_id = p.id
         JOIN book_copy AS bc ON b.id = bc.book_id
         JOIN book_author AS ba ON b.id = ba.book_id
         JOIN author AS a ON ba.author_id = a.id
         LEFT JOIN book_rating AS br ON b.id = br.book_id
         LEFT JOIN book_review AS rv ON b.id = rv.book_id
         LEFT JOIN book_borrow AS bb ON bc.id = bb.book_copy_id AND bb.book_return IS NULL;

--for testing
SELECT *
FROM book_details;
SELECT *
FROM book_details
WHERE book_title = 'The Catcher in the Rye';

--view 6  Check book availability, locations, and status of all copies – if available show location if not show user that has it (librarian)
--The view retrieves the book title, edition, format, status, and location of each book copy.
-- If the book is available, the location of the copy is displayed.
-- If the book is not available (i.e., it has been borrowed), the name of the patron who has borrowed the book is displayed.
-- The view also takes into account the fact that some copies may be borrowed by users by joining the book_copy table with the book_borrow table.
CREATE VIEW book_availability AS
SELECT book.title            AS book_title,
       book_copy.edition     AS edition,
       book_copy.book_format AS format,
       CASE
           WHEN book_copy.id IN (SELECT book_copy_id FROM book_borrow WHERE book_return is NULL) THEN 'BORROWED'
           ELSE 'AVAILABLE'
           END               AS status,
       CASE
           WHEN book_copy.id IN (SELECT book_copy_id FROM book_borrow)
               THEN (SELECT CONCAT(librarian.first_name, ' ', librarian.last_name)
                     FROM librarian
                              INNER JOIN book_borrow ON librarian.id = book_borrow.checkout_librarian_id
                     WHERE book_copy.id = book_borrow.book_copy_id)
           ELSE (SELECT CONCAT(book_location.section, '-', book_location.shelf)
                 FROM book_location
                 WHERE book_location.id = book_copy.location_id)
           END               AS location
FROM book_copy
         INNER JOIN book ON book_copy.book_id = book.id;


--view 11 show history of borrow
CREATE VIEW borrowed_books_history AS
SELECT b.id                               AS borrow_id,
       u.first_name || ' ' || u.last_name AS borrower_name,
       p.card_number,
       b.title                            AS book_title,
       a.author_name                      AS book_author,
       bc.book_format                     AS book_format,
       bb.book_checkout                   AS checkout_date,
       bb.book_return                     AS return_date,
       bb.damage                          AS damage_description,
       c.category_name                    AS category
FROM book_borrow bb
         JOIN patron p ON bb.user_id = p.id
         JOIN library_user u ON p.id = u.id
         JOIN book_copy bc ON bb.book_copy_id = bc.id
         JOIN book b ON bc.book_id = b.id
         JOIN book_author ba ON b.id = ba.book_id
         JOIN author a ON ba.author_id = a.id
         JOIN book_location bcl ON bc.location_id = bcl.id
         JOIN book_category bca ON b.id = bca.book_id
         JOIN category c ON bca.category_id = c.id;


