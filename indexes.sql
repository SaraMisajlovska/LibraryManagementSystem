INSERT INTO book (id,title, publisher_id, publication_date, summary, book_request_id)
VALUES (53334   ,'The Great Gatsby', 1, '2022-05-10', 'A classic novel by F. Scott Fitzgerald', NULL);

UPDATE book
SET title = 'New Title',
    publisher_id = 2,
    publication_date = '2023-01-01',
    summary = 'Updated summary'
WHERE id = 1;

CREATE INDEX idx_book_title ON book (title);

INSERT INTO book (id,title, publisher_id, publication_date, summary, book_request_id)
VALUES (53335   ,'The Great Gatsby', 1, '2022-05-10', 'A classic novel by F. Scott Fitzgerald', NULL);

UPDATE book
SET title = 'New Title',
    publisher_id = 2,
    publication_date = '2023-01-01',
    summary = 'Updated summary after index'
WHERE id = 2;

INSERT INTO library_user (id, email, user_password, first_name, last_name, date_of_birth, address, phone_number)
VALUES (12345678, 'example1@example.com', 'password123', 'John', 'Doe', '1990-01-01', '123 Main St, City', '1234567890');

INSERT INTO membership (id, price, package)
VALUES (123456,10.99, 'STANDARD');


INSERT INTO patron (id, email, user_password, first_name, last_name, date_of_birth, address, phone_number, card_number, membership_id)
VALUES (12345678, 'example1@example.com', 'password123', 'John', 'Doe', '1990-01-01', '123 Main St, City', '1234567890',123456788, 123456);

UPDATE patron
SET membership_id = 3
WHERE id = 12345678;

CREATE INDEX idx_patron_card_number ON patron (card_number);
