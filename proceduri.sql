-- 1. Create the login function
CREATE FUNCTION login(p_email varchar, p_password varchar)
    RETURNS BOOLEAN AS
$$
DECLARE
    user_exists BOOLEAN;
BEGIN
    -- Check if the user exists in the table
    SELECT EXISTS (SELECT 1
                   FROM library_user
                   WHERE email = p_email
                     AND user_password = p_password)
    INTO user_exists;

    RETURN user_exists;
END;
$$ LANGUAGE plpgsql;

-- test successful login
SELECT login('Evelyne.Racicot@library.com', 'pass61301');
-- test failed login
SELECT login('Evelyne.Racicot@library.com', '123');



-- 2. Create the register function for patron user
CREATE FUNCTION register_patron(
    p_email varchar,
    p_user_password varchar,
    p_first_name varchar,
    p_last_name varchar,
    p_date_of_birth date,
    p_address text,
    p_phone_number varchar,
    p_card_number integer,
    p_membership_id integer
)
    RETURNS VOID AS
$$
BEGIN
    -- Insert the patron into the patron table
    INSERT INTO patron (email, user_password, first_name, last_name, date_of_birth, address, phone_number, card_number,
                        membership_id)
    VALUES (p_email, p_user_password, p_first_name, p_last_name, p_date_of_birth, p_address, p_phone_number,
            p_card_number, p_membership_id);

    -- Check if the insert was successful
    IF FOUND THEN
        -- Output success message
        RAISE NOTICE 'Registration successful.';
    ELSE
        -- Output error message
        RAISE EXCEPTION 'Registration failed.';
    END IF;


    RETURN;
END;
$$ LANGUAGE plpgsql;

-- test successful patron register
SELECT register_patron(
               'test@test.com',
               'test123456',
               'Test',
               'Test',
               '1990-01-01',
               'Test',
               '1234567890',
               '123456',
               1
           );

-- test failed patron register (same query, but after success, this will fail)
SELECT register_patron(
               'test@test.com',
               'test123456',
               'Test',
               'Test',
               '1990-01-01',
               'Test',
               '1234567890',
               '123456',
               1
           );



-- 3. Search books by title, author or category
CREATE FUNCTION search_books(
    p_author_name varchar,
    p_title varchar,
    p_category_name varchar
)
    RETURNS TABLE
            (
                r_title            varchar,
                r_author_name      varchar,
                r_category_name    varchar,
                r_publication_date date
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT title, author_name, category_name, publication_date
        FROM book_search_view
        WHERE (p_author_name IS NULL OR author_name ILIKE '%' || p_author_name || '%')
          AND (p_title IS NULL OR title ILIKE '%' || p_title || '%')
          AND (p_category_name IS NULL OR category_name ILIKE '%' || p_category_name || '%');
END;
$$ LANGUAGE plpgsql;

-- test successful book search
SELECT *
FROM search_books('Tony Robbins', 'Female Intelligence', 'THRILLER');
SELECT *
FROM search_books('Tony Robbins', NULL, NULL);
SELECT *
FROM search_books(NULL, 'Female Intelligence', NULL);
SELECT *
FROM search_books(NULL, NULL, 'THRILLER');



-- 4. Search author by name
CREATE FUNCTION search_authors(p_author_name varchar)
    RETURNS TABLE
            (
                r_author_name varchar,
                r_birth_date  date,
                r_biography   text
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT author_name, birth_date, biography
        FROM author
        WHERE author_name ILIKE '%' || p_author_name || '%';
END;
$$ LANGUAGE plpgsql;

-- test successful author search
SELECT *
FROM search_authors('Tony Robbins');
SELECT *
FROM search_authors(NULL);



-- 5. Search events by name or date
CREATE FUNCTION search_events(p_event_name varchar, p_event_datetime date)
    RETURNS TABLE
            (
                r_event_name     varchar(255),
                r_description    text,
                r_event_datetime timestamp
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT event_name, description, event_datetime
        FROM library_event
        WHERE (p_event_name IS NULL OR event_name ILIKE '%' || p_event_name || '%')
          AND (p_event_datetime IS NULL OR DATE(event_datetime) = p_event_datetime);
END;
$$ LANGUAGE plpgsql;

-- test successful event search
SELECT *
FROM search_events('Baby Storytime', NULL);
SELECT *
FROM search_events('Baby Storytime', '2025-03-24');
SELECT *
FROM search_events(NULL, '2025-03-24');



-- 6. Insert a book copy (for librarian user)
CREATE FUNCTION insert_book_copy(
    p_book_id integer,
    p_location_id integer,
    p_edition integer,
    p_book_format varchar
)
    RETURNS VOID AS
$$
BEGIN
    -- Insert the book copy into the book_copy table
    INSERT INTO book_copy (book_id, location_id, edition, book_format)
    VALUES (p_book_id, p_location_id, p_edition, p_book_format);

    -- Check if the insert was successful
    IF FOUND THEN
        -- Output success message or perform additional actions
        RAISE NOTICE 'Book copy inserted successfully.';
    ELSE
        -- Output error message or perform error handling
        RAISE EXCEPTION 'Failed to insert book copy.';
    END IF;

    RETURN;
END;
$$ LANGUAGE plpgsql;

-- test insert book copy successfully
SELECT *
FROM insert_book_copy(10, 375, 1, 'PAPERBACK');



-- 7. Insert a book review (for patron user)
CREATE FUNCTION insert_book_review(
    p_patron_id integer,
    p_book_id integer,
    p_review text
)
    RETURNS VOID AS
$$
BEGIN
    -- Insert the book review into the book_review table
    INSERT INTO book_review (user_id, book_id, review)
    VALUES (p_patron_id, p_book_id, p_review);

    -- Check if the insert was successful
    IF FOUND THEN
        -- Output success message or perform additional actions
        RAISE NOTICE 'Book review inserted successfully.';
    ELSE
        -- Output error message or perform error handling
        RAISE EXCEPTION 'Failed to insert book review.';
    END IF;

    RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT insert_book_review(4, 1, 'This book is fantastic!');



-- 8. Borrow a book (librarian user to inserts book borrow for patron)
CREATE FUNCTION insert_book_borrow(
    p_user_id integer,
    p_book_copy_id integer,
    p_book_checkout date,
    p_checkout_librarian_id integer
)
    RETURNS void AS
$$
BEGIN
    INSERT INTO book_borrow (user_id, book_copy_id, book_checkout, checkout_librarian_id)
    VALUES (p_user_id, p_book_copy_id, p_book_checkout, p_checkout_librarian_id);

    -- Check if the insert was successful
    IF FOUND THEN
        -- Output success message or perform additional actions
        RAISE NOTICE 'Book borrow inserted successfully.';
    ELSE
        -- Output error message or perform error handling
        RAISE EXCEPTION 'Failed to insert book borrow.';
    END IF;

END;
$$
    LANGUAGE plpgsql;

-- test successful book borrow
SELECT insert_book_borrow(1, 4, '2023-05-31', 13);
-- test failed book borrow
SELECT insert_book_borrow(1, 2, '2023-05-31', 13);



-- 9. Book reservation (for patron user)
CREATE FUNCTION insert_book_reservation(
    p_book_copy_id integer,
    p_patron_id integer,
    p_reservation_date date
)
    RETURNS void AS
$$
BEGIN
    INSERT INTO book_reservation (book_copy_id, user_id, reservation_status, reservation_date)
    VALUES (p_book_copy_id, p_patron_id, 'ACTIVE', p_reservation_date);

    -- Check if the insert was successful
    IF FOUND THEN
        -- Output success message or perform additional actions
        RAISE NOTICE 'Book reservation inserted successfully.';
    ELSE
        -- Output error message or perform error handling
        RAISE EXCEPTION 'Failed to insert book reservation.';
    END IF;
END;
$$
    LANGUAGE plpgsql;

-- test successful book reservation
SELECT insert_book_reservation(4, 2, '2023-05-31');
-- test failed book reservation
SELECT insert_book_reservation(1, 2, '2023-05-31');



-- 10. Calculate the price for each day the book is not returned
CREATE FUNCTION calculate_total_price_for_unreturned_books(p_card_number integer, p_book_title varchar)
    RETURNS numeric AS
$$
DECLARE
    late_fee    numeric := 15; -- Late fee charge per day
    total_price numeric := 0; -- Total price to be paid
BEGIN
    SELECT COALESCE(SUM((days_borrowed - 21) * late_fee), 0)
    INTO total_price
    FROM unreturned_books
    WHERE card_number = p_card_number
      AND days_borrowed > 21
      AND (p_book_title is NULL OR title ILIKE '%' || p_book_title || '%');

    RETURN total_price;
END;
$$
    LANGUAGE plpgsql;

-- test total charge for a user for all unreturned books
SELECT calculate_total_price_for_unreturned_books(102045, NULL);
-- test total charge for a user for a specific unreturned book
SELECT calculate_total_price_for_unreturned_books(102045, 'Divine Secrets of the Ya-Ya Sisterhood : A Novel');
