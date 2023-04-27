--sequence that creates a patron card number and make it default for the patron's card_number
CREATE SEQUENCE IF NOT EXISTS card_number_seq
    increment 3
    start 100005;
ALTER TABLE patron ALTER COLUMN card_number SET DEFAULT nextval('card_number_seq');

-- insert statement that creates a patron from library_user
INSERT INTO patron (email, user_password, first_name, last_name, date_of_birth, address, phone_number,
                    membership_id)
SELECT u.email,
       u.user_password,
       u.first_name,
       u.last_name,
       u.date_of_birth,
       u.address,
       u.phone_number,
       (floor(random() * (3 - 1 + 1) + 1)::int)
FROM library_user u;
