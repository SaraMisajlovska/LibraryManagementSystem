
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