--Sequences
CREATE SEQUENCE book_seq START WITH 1000;
CREATE SEQUENCE member_seq START WITH 5000;
CREATE SEQUENCE borrowrecord_seq START WITH 9000;
CREATE SEQUENCE staff_seq START WITH 7000;

--Tables
CREATE TABLE book(
    ID NUMBER PRIMARY KEY,
    title VARCHAR2(250) NOT NULL,
    author VARCHAR2(250) NOT NULL,
    genre VARCHAR2(100),
    published_year NUMBER,
    stock NUMBER DEFAULT 0 NOT NULL,
    mod_user VARCHAR2(300) NOT NULL,
    created_on TIMESTAMP(6) NOT NULL,
    last_mod TIMESTAMP(6) NOT NULL,
    dml_flag VARCHAR2(1) NOT NULL CHECK (dml_flag IN ('I', 'U', 'D'))
);

CREATE TABLE MEMBER(
    ID NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    second_name VARCHAR2(50) NOT NULL,
    address VARCHAR2(500) NOT NULL,
    contact VARCHAR2(100) NOT NULL,
    mod_user VARCHAR2(300) NOT NULL,
    created_on TIMESTAMP(6) NOT NULL,
    last_mod TIMESTAMP(6) NOT NULL,
    dml_flag VARCHAR2(1) NOT NULL CHECK (dml_flag IN ('I', 'U', 'D'))
);

CREATE TABLE borrow_record (
    ID NUMBER PRIMARY KEY,
    member_id NUMBER NOT NULL,
    book_id NUMBER NOT NULL,
    borrow_date DATE DEFAULT SYSDATE NOT NULL,
    return_date DATE,
    CONSTRAINT fk_member FOREIGN KEY (member_id) REFERENCES member(ID),
    CONSTRAINT fk_book FOREIGN KEY (book_id) REFERENCES book(ID),
    mod_user VARCHAR2(300) NOT NULL,
    created_on TIMESTAMP(6) NOT NULL,
    last_mod TIMESTAMP(6) NOT NULL,
    dml_flag VARCHAR2(1) NOT NULL CHECK (dml_flag IN ('I', 'U', 'D'))
);

CREATE TABLE staff (
    ID NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    second_name VARCHAR2(50) NOT NULL,
    ROLE VARCHAR2(100),
    contact VARCHAR2(100),
    mod_user VARCHAR2(300) NOT NULL,
    created_on TIMESTAMP(6) NOT NULL,
    last_mod TIMESTAMP(6) NOT NULL,
    dml_flag VARCHAR2(1) NOT NULL CHECK (dml_flag IN ('I', 'U', 'D'))
);

--Triggers
CREATE OR REPLACE TRIGGER book_id_trigger
BEFORE INSERT ON book
FOR EACH ROW
BEGIN
    SELECT book_seq.NEXTVAL 
    INTO :NEW.ID 
    FROM DUAL;
END;

CREATE OR REPLACE TRIGGER member_id_trigger
BEFORE INSERT ON member
FOR EACH ROW
BEGIN
    SELECT member_seq.NEXTVAL 
    INTO :NEW.ID 
    FROM DUAL;
END;

CREATE OR REPLACE TRIGGER borrow_record_id_trigger
BEFORE INSERT ON borrow_record
FOR EACH ROW
BEGIN
    SELECT borrowrecord_seq.NEXTVAL 
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
CREATE OR REPLACE VIEW available_book AS
SELECT ID, title, author, genre, published_year, stock
FROM book
WHERE stock > 0;

CREATE OR REPLACE VIEW overdue_book AS
SELECT br.id, m.first_name, m.second_name, b.title, br.borrow_date, 
       TRUNC(SYSDATE - br.borrow_date) AS days_overdue
FROM borrow_record br
JOIN member m ON br.member_id = m.id
JOIN book b ON br.book_id = b.id
WHERE br.return_date IS NULL AND TRUNC(SYSDATE - br.borrow_date) > 14;

CREATE OR REPLACE VIEW member_borrow_history AS
SELECT m.id AS member_id, 
       m.first_name, 
       m.second_name, 
       b.title, 
       br.borrow_date, 
       br.return_date
FROM borrow_record br
JOIN member m ON br.member_id = m.id
JOIN book b ON br.book_id = b.id;
