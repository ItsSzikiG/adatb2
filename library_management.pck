CREATE OR REPLACE PACKAGE library_management IS

  FUNCTION check_book_availability(p_book_id IN NUMBER) RETURN NUMBER;
  PROCEDURE issue_book(p_member_id IN NUMBER
                      ,p_book_id   IN NUMBER);
  PROCEDURE add_book(p_title          IN VARCHAR2
                    ,p_author         IN VARCHAR2
                    ,p_genre          IN VARCHAR2 DEFAULT NULL
                    ,p_published_year IN NUMBER DEFAULT NULL
                    ,p_initial_stock  IN NUMBER DEFAULT 1);
  PROCEDURE add_member(p_first_name  IN VARCHAR2
                      ,p_second_name IN VARCHAR2
                      ,p_address     IN VARCHAR2 DEFAULT NULL
                      ,p_contact     IN VARCHAR2 DEFAULT NULL);
  PROCEDURE add_staff(p_first_name  IN VARCHAR2
                     ,p_second_name IN VARCHAR2
                     ,p_role        IN VARCHAR2 DEFAULT NULL
                     ,p_contact     IN VARCHAR2 DEFAULT NULL);
  PROCEDURE return_book(p_borrow_record_id IN NUMBER);

END library_management;
/
CREATE OR REPLACE PACKAGE BODY library_management IS

  --Check Book Availability
  FUNCTION check_book_availability(p_book_id IN NUMBER) RETURN NUMBER IS
    v_available_stock NUMBER;
  BEGIN
    SELECT stock INTO v_available_stock FROM book WHERE id = p_book_id;
  
    RETURN CASE WHEN v_available_stock > 0 THEN 1 ELSE 0 END;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN - 1;
    WHEN OTHERS THEN
      RETURN - 2;
  END check_book_availability;

  --Issue Book
  PROCEDURE issue_book(p_member_id IN NUMBER
                      ,p_book_id   IN NUMBER) IS
    v_book_stock NUMBER;
  BEGIN
    SELECT stock INTO v_book_stock FROM book WHERE id = p_book_id;
  
    IF v_book_stock <= 0
    THEN
      raise_application_error(-20001, 'Book not available in stock');
    END IF;
  
    INSERT INTO borrow_record
      (member_id
      ,book_id
      ,borrow_date)
    VALUES
      (p_member_id
      ,p_book_id
      ,SYSDATE);
  
    UPDATE book SET stock = stock - 1 WHERE id = p_book_id;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END issue_book;

  --Add Book
  PROCEDURE add_book(p_title          IN VARCHAR2
                    ,p_author         IN VARCHAR2
                    ,p_genre          IN VARCHAR2 DEFAULT NULL
                    ,p_published_year IN NUMBER DEFAULT NULL
                    ,p_initial_stock  IN NUMBER DEFAULT 1) IS
  BEGIN
    INSERT INTO book
      (title
      ,author
      ,genre
      ,published_year
      ,stock)
    VALUES
      (p_title
      ,p_author
      ,p_genre
      ,p_published_year
      ,p_initial_stock);
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20002, 'Failed to add book: ' || SQLERRM);
  END add_book;

  --Add member
  PROCEDURE add_member(p_first_name  IN VARCHAR2
                      ,p_second_name IN VARCHAR2
                      ,p_address     IN VARCHAR2 DEFAULT NULL
                      ,p_contact     IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    INSERT INTO MEMBER
      (first_name
      ,second_name
      ,address
      ,contact)
    VALUES
      (p_first_name
      ,p_second_name
      ,p_address
      ,p_contact);
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20003, 'Failed to add member: ' || SQLERRM);
  END add_member;

  --Add Staff
  PROCEDURE add_staff(p_first_name  IN VARCHAR2
                     ,p_second_name IN VARCHAR2
                     ,p_role        IN VARCHAR2 DEFAULT NULL
                     ,p_contact     IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    INSERT INTO staff
      (first_name
      ,second_name
      ,role
      ,contact)
    VALUES
      (p_first_name
      ,p_second_name
      ,p_role
      ,p_contact);
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20005, 'Failed to add staff: ' || SQLERRM);
  END add_staff;

  --Return Book
  PROCEDURE return_book(p_borrow_record_id IN NUMBER) IS
    v_book_id NUMBER;
  BEGIN
    UPDATE borrow_record
       SET return_date = SYSDATE
     WHERE id = p_borrow_record_id
    RETURNING book_id INTO v_book_id;
  
    UPDATE book SET stock = stock + 1 WHERE id = v_book_id;
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20004, 'Failed to return book: ' || SQLERRM);
  END return_book;

END library_management;
/
