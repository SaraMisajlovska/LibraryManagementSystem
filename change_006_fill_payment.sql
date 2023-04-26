CREATE TABLE payment
(
    id             SERIAL PRIMARY KEY,
    payment_date   DATE              NOT NULL,
    membership_id  INTEGER           NOT NULL REFERENCES membership (id),
    payment_method VARCHAR(255)      NOT NULL CHECK (payment_method IN ('CASH', 'CARD')),
    user_id        INTEGER DEFAULT 0 NOT NULL REFERENCES patron (id) ON DELETE SET DEFAULT
);
drop table payment;

CREATE OR REPLACE FUNCTION random_payment_date()
RETURNS TIMESTAMP
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN NOW() - INTERVAL '1 day' - (random() * INTERVAL '10 years');
END $$;

INSERT INTO payment (payment_date, membership_id, payment_method, user_id)
SELECT random_payment_date() AS payment_date,
       (floor(random() * (3 - 1 + 1) + 1)::int)                             as membership_id,
       CASE WHEN random() < 0.4 THEN 'CASH' ELSE 'CARD' END                 AS payment_method,
       patron.id                                                            as user_id
FROM patron
CROSS JOIN generate_series(1,600);