--register
CREATE OR REPLACE FUNCTION create_patron(
    p_card_number INTEGER,
    p_membership_id INTEGER,
    p_email VARCHAR(255),
    p_user_password VARCHAR(255),
    p_first_name VARCHAR(255),
    p_last_name VARCHAR(255),
    p_date_of_birth DATE,
    p_address TEXT,
    p_phone_number VARCHAR(20)
) RETURNS VOID AS
$$
BEGIN
    INSERT INTO patron (card_number, membership_id, email, user_password, first_name, last_name, date_of_birth, address,
                        phone_number)
    VALUES (p_card_number, p_membership_id, p_email, p_user_password, p_first_name, p_last_name, p_date_of_birth,
            p_address, p_phone_number);
END;


--login patron
    CREATE OR REPLACE PROCEDURE patron_login(
    p_email VARCHAR(255),
    p_password VARCHAR(255),
    OUT p_user_id INTEGER,
    OUT p_login_success BOOLEAN
) AS $$
BEGIN
p_user_id := NULL;
p_login_success := FALSE;

SELECT id
INTO p_user_id
FROM library_user
WHERE email = p_email
  AND user_password = p_password;

IF p_user_id IS NOT NULL THEN
        p_login_success := TRUE;
END IF;
END;


--Get the total number of books borrowed by a patron
CREATE OR REPLACE FUNCTION get_total_borrowed_books(
    p_patron_id INTEGER
) RETURNS INTEGER AS
$$
DECLARE
    total_borrowed INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO total_borrowed
    FROM book_borrow
    WHERE user_id = p_patron_id;

    RETURN total_borrowed;
END;


--List authors by name
    CREATE OR REPLACE PROCEDURE list_authors_by_name(
    p_name VARCHAR(255)
) AS $$
BEGIN
SELECT *
FROM author
WHERE author_name ILIKE '%' || p_name || '%';
END;


-- List events by date or title
CREATE OR REPLACE PROCEDURE list_events_by_date_and_title(
    p_start_date DATE,
    p_end_date DATE,
    p_title VARCHAR(255)
) AS
$$
BEGIN
    SELECT *
    FROM library_event
    WHERE (event_datetime >= p_start_date AND event_datetime <= p_end_date)
       OR event_name ILIKE '%' || p_title || '%';
END;


--Search books by category
    CREATE OR REPLACE FUNCTION search_books_by_category(
    p_category_name VARCHAR(255)
) RETURNS TABLE (
    book_id INTEGER,
    title VARCHAR(255),
    publisher_id INTEGER,
    publication_date DATE,
    summary TEXT,
    edition INTEGER,
    book_format VARCHAR(255)
) AS $$
BEGIN
RETURN QUERY
SELECT b.id, b.title, b.publisher_id, b.publication_date, b.summary, bc.edition, bc.book_format
FROM book b
         JOIN book_category bc ON b.id = bc.book_id
         JOIN category c ON bc.category_id = c.id
WHERE c.category_name = p_category_name;

RETURN;
END;


--How many events has a user visited
CREATE OR REPLACE FUNCTION count_visited_events(
    p_user_id INTEGER
) RETURNS INTEGER AS
$$
DECLARE
    visited_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO visited_count
    FROM event_users eu
    WHERE eu.user_id = p_user_id;

    RETURN visited_count;
END;


--Calculate late fee for a book return
    CREATE OR REPLACE FUNCTION calculate_late_fee(
    p_borrow_id INTEGER
) RETURNS NUMERIC AS $$
DECLARE
    days_late INTEGER;
late_fee NUMERIC;
BEGIN
SELECT EXTRACT(DAY FROM (bb.book_return - bb.book_checkout))
INTO days_late
FROM book_borrow bb
WHERE bb.id = p_borrow_id;

IF days_late > 0 THEN
        late_fee := days_late * 0.5; -- Assuming $0.50 per day late fee
ELSE
        late_fee := 0;
END IF;

RETURN late_fee;
END;


--Update book reservation status to expired
CREATE OR REPLACE PROCEDURE expire_book_reservations() AS
$$
BEGIN
    UPDATE book_reservation
    SET reservation_status = 'EXPIRED'
    WHERE reservation_date < CURRENT_DATE;
END;


--Leave Book Review
    CREATE OR REPLACE PROCEDURE leave_book_review(
    p_patron_id INTEGER,
    p_book_id INTEGER,
    p_review TEXT
) AS $$
BEGIN
-- Check if the book exists
IF NOT EXISTS (SELECT 1 FROM book WHERE id = p_book_id) THEN
        RAISE EXCEPTION 'Book with ID % does not exist.', p_book_id;
END IF;

-- Insert the review into the book_review table
INSERT INTO book_review (user_id, book_id, review)
VALUES (p_patron_id, p_book_id, p_review);

RAISE NOTICE 'Review for Book with ID % has been successfully added.', p_book_id;
END;







