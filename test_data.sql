--Add Books
BEGIN
  library_management.add_book('To Kill a Mockingbird', 'Harper Lee', 'Fiction', 1960, 5);
  library_management.add_book('1984', 'George Orwell', 'Dystopian', 1949, 10);
  library_management.add_book('The Great Gatsby', 'F. Scott Fitzgerald', 'Classic', 1925, 3);
  library_management.add_book('Moby Dick', 'Herman Melville', 'Adventure', 1851, 2);
  library_management.add_book('Pride and Prejudice', 'Jane Austen', 'Romance', 1813, 4);
  library_management.add_book('A Tale of Two Cities', 'Charles Dickens', 'Historical Fiction', 1859, 0);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error adding test books: ' || SQLERRM);
END;
/

--Add Members
BEGIN
  library_management.add_member('Alice', 'Johnson', '123 Elm Street, Springfield', '555-1234');
  library_management.add_member('Bob', 'Williams', '456 Oak Avenue, Shelbyville', '555-5678');
  library_management.add_member('Cathy', 'Davis', '789 Birch Lane, Capital City', '555-9012');
  library_management.add_member('David', 'Evans', '321 Pine Road, Ogdenville', '555-3456');
  library_management.add_member('Eva', 'Martin', '654 Maple Lane, North Haverbrook', '555-7890');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error adding test members: ' || SQLERRM);
END;
/

--Add Staff
BEGIN
  library_management.add_staff('John', 'Doe', 'Librarian', '123-456-7890');
  library_management.add_staff('Jane', 'Smith', 'Assistant', '234-567-8901');
  library_management.add_staff('Emily', 'Clark', 'Manager', '345-678-9012');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error adding test staff: ' || SQLERRM);
END;
/



