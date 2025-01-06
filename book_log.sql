--History table
CREATE TABLE book_history (
    id NUMBER,
    title VARCHAR2(250),
    author VARCHAR2(250),
    genre VARCHAR2(100),
    published_year NUMBER,
    stock NUMBER,
    mod_user VARCHAR2(300),
    created_on TIMESTAMP(6),
    last_mod TIMESTAMP(6),
    dml_flag VARCHAR2(1)
);

--History trigger
CREATE OR REPLACE TRIGGER book_history_trg
AFTER DELETE OR UPDATE OR INSERT ON book
FOR EACH ROW
BEGIN
    
    IF INSERTING THEN
        INSERT INTO book_history (
            id, title, author, genre, published_year, stock,
            mod_user, created_on, last_mod, dml_flag
        ) VALUES (
            :NEW.id, :NEW.title, :NEW.author, :NEW.genre, :NEW.published_year, :NEW.stock,
            SYS_CONTEXT('USERENV', 'SESSION_USER'),
            :NEW.created_on, SYSTIMESTAMP, 'I'
        );
    
    ELSIF UPDATING THEN
        INSERT INTO book_history (
            id, title, author, genre, published_year, stock,
            mod_user, created_on, last_mod, dml_flag
        ) VALUES (
            :NEW.id, :NEW.title, :NEW.author, :NEW.genre, :NEW.published_year, :NEW.stock,
            SYS_CONTEXT('USERENV', 'SESSION_USER'),
            :NEW.created_on, SYSTIMESTAMP, 'U'
        );
    
    ELSIF DELETING THEN
        INSERT INTO book_history (
            id, title, author, genre, published_year, stock,
            mod_user, created_on, last_mod, dml_flag
        ) VALUES (
            :OLD.id, :OLD.title, :OLD.author, :OLD.genre, :OLD.published_year, :OLD.stock,
            SYS_CONTEXT('USERENV', 'SESSION_USER'),
            :OLD.created_on, SYSTIMESTAMP, 'D'
        );
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error in book_history_trg: ' || SQLERRM);
        RAISE;
END;
/

--Audit trigger
CREATE OR REPLACE TRIGGER book_audit_trg
BEFORE INSERT OR UPDATE ON book
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
