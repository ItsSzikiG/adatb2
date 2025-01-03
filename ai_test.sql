select * from books;
select * from members;
select * from borrow_records;
select * from staff;

DECLARE
  v_availability NUMBER;
BEGIN
  v_availability := library_management.check_book_availability(1030);
  DBMS_OUTPUT.PUT_LINE('Book availability (should be 1): ' || v_availability);
  
  library_management.issue_book(5000, 1030);
  DBMS_OUTPUT.PUT_LINE('Book borrowed successfully');
 EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in test procedures: ' || SQLERRM);
    ROLLBACK;
END;
/

-- Test book availability checking and borrowing
DECLARE
  v_availability NUMBER;
  v_member_id NUMBER;
  v_book_id NUMBER;
  v_borrow_id NUMBER;

  -- Get first book and member IDs for testing
  SELECT id INTO v_book_id FROM books WHERE title = 'To Kill a Mockingbird';
  SELECT id INTO v_member_id FROM members WHERE first_name = 'Alice';
  
  -- Test availability check
  v_availability := library_management.check_book_availability(1010);
  DBMS_OUTPUT.PUT_LINE('Book availability (should be 1): ' || v_availability);
  
  -- Test book borrowing
  library_management.issue_book(v_member_id, v_book_id);
  DBMS_OUTPUT.PUT_LINE('Book borrowed successfully');
  
  -- Check updated availability
  v_availability := library_management.check_book_availability(v_book_id);
  DBMS_OUTPUT.PUT_LINE('Book availability after borrow (should be 1 if stock > 1): ' || v_availability);
  
  -- Get the borrow record ID for return test
  SELECT id INTO v_borrow_id 
  FROM borrow_records 
  WHERE member_id = v_member_id 
  AND book_id = v_book_id 
  AND return_date IS NULL;
  
  -- Test book return
  library_management.return_book(v_borrow_id);
  DBMS_OUTPUT.PUT_LINE('Book returned successfully');
  
  -- Final availability check
  v_availability := library_management.check_book_availability(v_book_id);
  DBMS_OUTPUT.PUT_LINE('Book availability after return (should be 1): ' || v_availability);
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in test procedures: ' || SQLERRM);
    ROLLBACK;
END;
/

-- Test edge cases
DECLARE
  v_invalid_book_id NUMBER := 99999;
  v_invalid_member_id NUMBER := 99999;
  v_availability NUMBER;
BEGIN
  -- Test non-existent book availability
  v_availability := library_management.check_book_availability(v_invalid_book_id);
  DBMS_OUTPUT.PUT_LINE('Invalid book availability (should be -1): ' || v_availability);
  
  -- Test borrowing with invalid member
  BEGIN
    library_management.issue_book(v_invalid_member_id, v_invalid_book_id);
    DBMS_OUTPUT.PUT_LINE('This line should not execute');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Expected error caught for invalid member/book: ' || SQLERRM);
  END;
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in edge case tests: ' || SQLERRM);
    ROLLBACK;
END;
/
