SELECT * FROM book;
SELECT * FROM member;
SELECT * FROM borrow_record;
SELECT * FROM staff;

SELECT * FROM available_book;
SELECT * FROM overdue_book;

-- Test book availability checking and borrowing
DECLARE
  v_availability NUMBER;
  v_member_id    NUMBER;
  v_book_id      NUMBER;
  v_borrow_id    NUMBER;
BEGIN
  -- Get first book and member IDs for testing
  SELECT id INTO v_book_id FROM book WHERE title = 'To Kill a Mockingbird';
  SELECT id INTO v_member_id FROM member WHERE first_name = 'Alice';

  -- Test availability check
  v_availability       := library_management.check_book_availability(v_book_id);
  dbms_output.put_line('Book availability (should be 1): ' || v_availability);

  -- Test book borrowing
  library_management.issue_book(v_member_id, v_book_id);
  dbms_output.put_line         ('Book borrowed successfully');

  -- Check updated availability
  v_availability       := library_management.check_book_availability(v_book_id);
  dbms_output.put_line('Book availability after borrow (should be 1 if stock > 1): ' || v_availability);

  -- Get the borrow record ID for return test
  SELECT id INTO v_borrow_id FROM borrow_record WHERE member_id = v_member_id AND book_id = v_book_id AND return_date IS NULL;

  -- Test book return
  library_management.return_book(v_borrow_id);
  dbms_output.put_line          ('Book returned successfully');

  -- Final availability check
  v_availability       := library_management.check_book_availability(v_book_id);
  dbms_output.put_line('Book availability after return (should be 1): ' || v_availability);

  EXCEPTION WHEN OTHERS THEN dbms_output.put_line('Error in test procedures: ' || SQLERRM);
  ROLLBACK ;
END;
/

SELECT * FROM borrow_record_history;
SELECT * FROM book_history;
SELECT * FROM member_history;
SELECT * FROM staff_history;
