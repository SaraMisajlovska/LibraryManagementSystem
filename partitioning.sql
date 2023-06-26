CREATE TABLE book_borrow_returned (
    CHECK (book_return IS NOT NULL)
) INHERITS (book_borrow);

CREATE TABLE book_borrow_not_returned (
    CHECK (book_return IS NULL)
) INHERITS (book_borrow);

-- Insert existing data into partitions
INSERT INTO book_borrow_returned
SELECT *
FROM book_borrow
WHERE book_return IS NOT NULL;

INSERT INTO book_borrow_not_returned
SELECT *
FROM book_borrow
WHERE book_return IS NULL;

-- Create necessary indexes and constraints
-- Replace with your desired indexes and constraints
CREATE INDEX idx_book_borrow_returned ON book_borrow_returned (book_copy_id);
CREATE INDEX idx_book_borrow_not_returned ON book_borrow_not_returned (book_copy_id);

CREATE TABLE book_borrow_not_damaged (
    CHECK (damage LIKE 'No damage')
) INHERITS (book_borrow_returned);

-- Insert existing data into partitions
INSERT INTO book_borrow_not_damaged
SELECT *
FROM book_borrow_returned
WHERE damage LIKE 'No damage';

-- Create necessary indexes and constraints
-- Replace with your desired indexes and constraints
CREATE INDEX idx_book_borrow_not_damaged ON book_borrow_not_damaged (book_copy_id);