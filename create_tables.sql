--Sequences
CREATE SEQUENCE books_seq START WITH 1000;
CREATE SEQUENCE members_seq START WITH 5000;
CREATE SEQUENCE borrowrecords_seq START WITH 9000;
CREATE SEQUENCE staff_seq START WITH 7000;

--Tables
CREATE TABLE books(
    ID NUMBER PRIMARY KEY,
    title VARCHAR2(250) NOT NULL,
    author VARCHAR2(250) NOT NULL,
    genre Varchar2(100),
    published_year NUMBER,
    stock NUMBER default 0 not null
);

CREATE TABLE members(
    ID NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    second_name VARCHAR2(50) NOT NULL,
    address VARCHAR2(500) NOT NULL,
    contact VARCHAR2(100) NOT NULL
);

CREATE TABLE borrow_records (
    ID NUMBER PRIMARY KEY,
    member_id NUMBER NOT NULL,
    book_id NUMBER NOT NULL,
    borrow_date DATE DEFAULT SYSDATE NOT NULL,
    return_date DATE,
    CONSTRAINT fk_member FOREIGN KEY (member_id) REFERENCES members(ID),
    CONSTRAINT fk_book FOREIGN KEY (book_id) REFERENCES books(ID)
);

CREATE TABLE staff (
    ID NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    second_name VARCHAR2(50) NOT NULL,
    role VARCHAR2(100),
    contact VARCHAR2(100)
);

--Triggers
CREATE OR REPLACE TRIGGER books_id_trigger
BEFORE INSERT ON books
FOR EACH ROW
BEGIN
    SELECT books_seq.NEXTVAL 
    INTO :NEW.ID 
    FROM DUAL;
END;

CREATE OR REPLACE TRIGGER members_id_trigger
BEFORE INSERT ON members
FOR EACH ROW
BEGIN
    SELECT members_seq.NEXTVAL 
    INTO :NEW.ID 
    FROM DUAL;
END;

CREATE OR REPLACE TRIGGER borrow_records_id_trigger
BEFORE INSERT ON borrow_records
FOR EACH ROW
BEGIN
    SELECT borrowrecords_seq.NEXTVAL 
    INTO :NEW.ID 
    FROM DUAL;
END;

CREATE OR REPLACE TRIGGER staff_id_trigger
BEFORE INSERT ON staff
FOR EACH ROW
BEGIN
    SELECT staff_seq.NEXTVAL 
    INTO :NEW.ID 
    FROM DUAL;
END;

--Views
CREATE OR REPLACE VIEW available_books AS
SELECT id, title, author, genre, published_year, stock
FROM books
WHERE stock > 0;

CREATE OR REPLACE VIEW overdue_books AS
SELECT br.id, m.first_name, m.second_name, b.title, br.borrow_date, 
       TRUNC(SYSDATE - br.borrow_date) AS days_overdue
FROM borrow_records br
JOIN members m ON br.member_id = m.id
JOIN books b ON br.book_id = b.id
WHERE br.return_date IS NULL AND TRUNC(SYSDATE - br.borrow_date) > 14;

CREATE OR REPLACE VIEW member_borrow_history AS
SELECT m.id AS member_id, 
       m.first_name, 
       m.second_name, 
       b.title, 
       br.borrow_date, 
       br.return_date
FROM borrow_records br
JOIN members m ON br.member_id = m.id
JOIN books b ON br.book_id = b.id;
