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
       m.package AS membership_package
FROM library_user u
         JOIN patron p ON u.id = p.id
         JOIN membership m ON p.membership_id = m.id;

--view 2 - browse events
CREATE MATERIALIZED VIEW event_attendance AS
SELECT e.id as event_id, e.event_name, e.description, e.event_datetime, COUNT(DISTINCT eu.user_id) as num_attendees
FROM library_event e
JOIN event_users eu ON eu.event_id = e.id
GROUP BY e.id, e.event_name, e.description, e.event_datetime;

refresh materialized view event_attendance;