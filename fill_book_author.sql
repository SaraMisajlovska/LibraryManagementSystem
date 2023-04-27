INSERT INTO book_author(book_id, author_id)
SELECT book.id, author.id FROM book NATURAL JOIN author
