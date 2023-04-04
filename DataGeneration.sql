INSERT INTO membership (price, package)
VALUES (150.0, 'STUDENT'),
       (200.0, 'STANDARD'),
       (300.0, 'SENIOR');

CREATE SEQUENCE patron_sequence
    increment 3
    start 100000;

SELECT nextval('patron_sequence');

-- loop for creating a patron from lib user, remove loops
do
$$
    declare
        tmp_user record;
        card_num integer;
        mem_id integer;
    begin
        for tmp_user in select email, user_password, first_name, last_name, date_of_birth, address, phone_number
                        from library_user
            loop
                card_num = (select nextval('patron_sequence'));
                mem_id = (floor(random() * (6-4+1) + 4)::int);
                INSERT
                INTO patron ( email, user_password, first_name, last_name, date_of_birth, address, phone_number,
                             card_number,
                             membership_id)

                VALUES (tmp_user.email, tmp_user.user_password, tmp_user.first_name, tmp_user.last_name,
                        tmp_user.date_of_birth, tmp_user.address, tmp_user.phone_number, card_num, mem_id);
            end loop;
    end;
$$;

