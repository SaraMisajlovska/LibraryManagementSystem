-- Create membership table
CREATE TABLE membership
(
    id      SERIAL PRIMARY KEY,
    price   NUMERIC(10, 2) NOT NULL,
    package VARCHAR(255)   NOT NULL CHECK (package IN ('STUDENT', 'STANDARD', 'SENIOR'))
);

-- Create User table
CREATE TABLE library_user
(
    id            SERIAL PRIMARY KEY,
    email         VARCHAR(255) UNIQUE NOT NULL,
    user_password VARCHAR(255)        NOT NULL,
    first_name    VARCHAR(255)        NOT NULL,
    last_name     VARCHAR(255)        NOT NULL,
    date_of_birth DATE                NOT NULL,
    address       TEXT                NOT NULL,
    phone_number  VARCHAR(20)         NOT NULL CHECK (phone_number ~ '^[0-9]{10}$'),
    CONSTRAINT CK_user_password CHECK (char_length(user_password) >= 8)
);

-- Create the patron table that inherits from user
CREATE TABLE patron
(
    card_number   INTEGER UNIQUE NOT NULL,
    membership_id INTEGER        NOT NULL REFERENCES membership (id),
    id            SERIAL PRIMARY KEY
) INHERITS (library_user);

-- Create the librarian table that inherits from user
CREATE TABLE librarian
(
    job_title VARCHAR(255) NOT NULL,
    hire_date DATE         NOT NULL,
    id        SERIAL PRIMARY KEY
) INHERITS (library_user);

-- Create category table
CREATE TABLE category
(
    id            SERIAL PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL CHECK ( category_name IN ('ADVENTURE',
                                                                  'BIOGRAPHY',
                                                                  'CHILDREN',
                                                                  'DRAMA',
                                                                  'EDUCATION',
                                                                  'FANTASY',
                                                                  'HISTORY',
                                                                  'HORROR',
                                                                  'MANGA',
                                                                  'MYSTERY',
                                                                  'POETRY',
                                                                  'ROMANCE',
                                                                  'SCIENCE_FICTION',
                                                                  'SELF_HELP',
                                                                  'THRILLER',
                                                                  'TRAVEL'))
);

-- Create publisher table
CREATE TABLE publisher
(
    id                SERIAL PRIMARY KEY,
    publisher_name    VARCHAR(255) NOT NULL,
    publisher_address VARCHAR(255) NOT NULL,
    contact           VARCHAR(255) NOT NULL
);

-- Create author table
CREATE TABLE author
(
    id          SERIAL PRIMARY KEY,
    author_name VARCHAR(255) NOT NULL,
    birth_date  DATE         NOT NULL,
    biography   TEXT         NULL
);

-- Create book_request table
CREATE TABLE book_request
(
    id         SERIAL PRIMARY KEY,
    user_id    INTEGER DEFAULT 0 NOT NULL REFERENCES patron (id) ON DELETE SET DEFAULT,
    book_title VARCHAR(255)      NOT NULL,
    author     VARCHAR(255)      NOT NULL
);

-- Create book table
CREATE TABLE book
(
    id               SERIAL PRIMARY KEY,
    title            VARCHAR(255) NOT NULL,
    publisher_id     INTEGER      NOT NULL REFERENCES publisher (id),
    publication_date DATE         NOT NULL,
    summary          TEXT         NOT NULL,
    book_request_id  INTEGER      NULL REFERENCES book_request (id)
);

-- Create payment table
CREATE TABLE payment
(
    id             SERIAL PRIMARY KEY,
    payment_date   DATE              NOT NULL,
    membership_id  INTEGER           NOT NULL REFERENCES membership (id),
    payment_method VARCHAR(255)      NOT NULL CHECK (payment_method IN ('CASH', 'CARD')),
    user_id        INTEGER DEFAULT 0 NOT NULL REFERENCES patron (id) ON DELETE SET DEFAULT
);

-- Create book_location table
CREATE TABLE book_location
(
    id      SERIAL PRIMARY KEY,
    section VARCHAR(50) NOT NULL,
    shelf   INTEGER     NOT NULL
);

-- Create book_copy table
CREATE TABLE book_copy
(
    id          SERIAL PRIMARY KEY,
    book_id     INTEGER      NOT NULL REFERENCES book (id),
    location_id INTEGER      NOT NULL REFERENCES book_location (id),
    edition     INTEGER      NOT NULL,
    book_format VARCHAR(255) NOT NULL CHECK ( book_format IN ('PAPERBACK', 'HARDCOVER'))
);

-- Create book_author table
CREATE TABLE book_author
(
    book_id   INTEGER NOT NULL REFERENCES book (id),
    author_id INTEGER NOT NULL REFERENCES author (id),
    PRIMARY KEY (book_id, author_id)
);

-- Create book_category table
CREATE TABLE book_category
(
    book_id     INTEGER NOT NULL REFERENCES book (id),
    category_id INTEGER NOT NULL REFERENCES category (id),
    PRIMARY KEY (book_id, category_id)
);

-- Create book_review table
CREATE TABLE book_review
(
    id      SERIAL PRIMARY KEY,
    user_id INTEGER DEFAULT 0 NOT NULL REFERENCES patron (id) ON DELETE SET DEFAULT,
    book_id INTEGER           NOT NULL REFERENCES book (id),
    review  TEXT              NOT NULL
);

-- Create book_rating table
CREATE TABLE book_rating
(
    id      SERIAL PRIMARY KEY,
    user_id INTEGER DEFAULT 0 NOT NULL REFERENCES patron (id) ON DELETE SET DEFAULT,
    book_id INTEGER           NOT NULL REFERENCES book (id),
    rating  INTEGER           NOT NULL
);

-- Create reading_list table
CREATE TABLE reading_list
(
    user_id INTEGER DEFAULT 0 NOT NULL REFERENCES patron (id) ON DELETE SET DEFAULT,
    book_id INTEGER           NOT NULL REFERENCES book (id),
    PRIMARY KEY (user_id, book_id)
);

CREATE TABLE book_borrow
(
    id                    SERIAL PRIMARY KEY,
    user_id               INTEGER DEFAULT 0 NOT NULL REFERENCES patron (id) ON DELETE SET DEFAULT,
    book_copy_id          INTEGER           NOT NULL REFERENCES book_copy (id),
    book_checkout         DATE              NOT NULL,
    book_return           DATE              NULL,
    damage                VARCHAR(255)      NULL,
    checkout_librarian_id INTEGER DEFAULT 0 NOT NULL REFERENCES librarian (id) ON DELETE SET DEFAULT,
    return_librarian_id   INTEGER DEFAULT 0 NOT NULL REFERENCES librarian (id) ON DELETE SET DEFAULT
);

CREATE TABLE book_reservation
(
    id                 SERIAL PRIMARY KEY,
    book_copy_id       INTEGER           NOT NULL REFERENCES book_copy (id),
    user_id            INTEGER DEFAULT 0 NOT NULL REFERENCES patron (id) ON DELETE SET DEFAULT,
    reservation_status VARCHAR(255)      NOT NUll CHECK (reservation_status IN ('ACTIVE', 'CANCELLED', 'EXPIRED', 'CHECKED_OUT')),
    reservation_date   DATE              NOT NULL CHECK (reservation_date >= CURRENT_DATE)
);

CREATE TABLE library_event
(
    id             SERIAL PRIMARY KEY,
    event_name     VARCHAR(255) NOT NULL,
    description    TEXT         NOT NULL,
    event_datetime TIMESTAMP    NOT NULL CHECK (event_datetime >= CURRENT_TIMESTAMP)
);

CREATE TABLE event_users
(
    id        SERIAL PRIMARY KEY,
    event_id  INTEGER           NOT NULL REFERENCES library_event (id) ON DELETE SET DEFAULT,
    user_id   INTEGER DEFAULT 0 NOT NULL REFERENCES library_user (id) ON DELETE SET DEFAULT,
    user_type VARCHAR(255)      NOT NULL CHECK ( user_type IN ('PATRON', 'LIBRARIAN'))
);