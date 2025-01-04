--Sequence
CREATE SEQUENCE books_history_seq START WITH 1;

--History table
CREATE TABLE books_history (
    history_id NUMBER PRIMARY KEY,
    id NUMBER NOT NULL,
    title VARCHAR2(250),
    author VARCHAR2(250),
    genre VARCHAR2(100),
    published_year NUMBER,
    stock NUMBER,
    mod_user VARCHAR2(300) NOT NULL,
    created_on TIMESTAMP(6) NOT NULL,
    last_mod TIMESTAMP(6) NOT NULL,
    dml_flag VARCHAR2(1) NOT NULL CHECK (dml_flag IN ('I', 'U', 'D'))
);

--History trigger
CREATE OR REPLACE TRIGGER books_history_trg
AFTER DELETE OR UPDATE OR INSERT ON books
FOR EACH ROW
BEGIN
    
    IF INSERTING THEN
        INSERT INTO books_history (
            history_id, id, title, author, genre, published_year, stock,
            mod_user, created_on, last_mod, dml_flag
        ) VALUES (
            books_history_seq.NEXTVAL,
            :NEW.id, :NEW.title, :NEW.author, :NEW.genre, :NEW.published_year, :NEW.stock,
            SYS_CONTEXT('USERENV', 'SESSION_USER'),
            :NEW.created_on, SYSTIMESTAMP, 'I'
        );
    
    ELSIF UPDATING THEN
        INSERT INTO books_history (
            history_id, id, title, author, genre, published_year, stock,
            mod_user, created_on, last_mod, dml_flag
        ) VALUES (
            books_history_seq.NEXTVAL,
            :NEW.id, :NEW.title, :NEW.author, :NEW.genre, :NEW.published_year, :NEW.stock,
            SYS_CONTEXT('USERENV', 'SESSION_USER'),
            :NEW.created_on, SYSTIMESTAMP, 'U'
        );
    
    ELSIF DELETING THEN
        INSERT INTO books_history (
            history_id, id, title, author, genre, published_year, stock,
            mod_user, created_on, last_mod, dml_flag
        ) VALUES (
            books_history_seq.NEXTVAL,
            :OLD.id, :OLD.title, :OLD.author, :OLD.genre, :OLD.published_year, :OLD.stock,
            SYS_CONTEXT('USERENV', 'SESSION_USER'),
            :OLD.created_on, SYSTIMESTAMP, 'D'
        );
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error in books_history_trg: ' || SQLERRM);
        RAISE;
END;
/

--Audit trigger
CREATE OR REPLACE TRIGGER books_audit_trg
BEFORE INSERT OR UPDATE ON books
FOR EACH ROW 
BEGIN 
    IF INSERTING THEN
        :NEW.created_on := SYSTIMESTAMP;
        :NEW.last_mod := SYSTIMESTAMP;
        :NEW.dml_flag := 'I';
        :NEW.mod_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
    ELSIF UPDATING THEN
        :NEW.last_mod := SYSTIMESTAMP;
        :NEW.dml_flag := 'U';
        :NEW.mod_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
    END IF;
END;
/
