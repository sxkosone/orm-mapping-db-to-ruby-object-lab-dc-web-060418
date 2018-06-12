require 'pry'
class Student
  attr_accessor :id, :name, :grade

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    student = Student.new
    student.id = row[0]
    student.name = row[1]
    student.grade = row[2]
    student
  end

  def self.all
    # retrieve all the rows from the "Students" database
    sql = <<-SQL
    SELECT * FROM students
    SQL
    all = DB[:conn].execute(sql)
    # remember each row should be a new instance of the Student class
    all.collect do |row|
      Student.new_from_db(row)
    end
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    sql = <<-SQL
    SELECT * FROM students
    WHERE name = ?
    SQL
    found = DB[:conn].execute(sql, name) #found is an array with one element, the row
    # return a new instance of the Student class
    Student.new_from_db(found[0])
  end

  def self.many_objects_from_db(sql)
    #Helper method to return an array of objects from database rows
    #takes in a sql command
    results = DB[:conn].execute(sql)
    results.map do |row|
      Student.new_from_db(row)
    end
  end

  def self.count_all_students_in_grade_9
    sql = <<-SQL
    SELECT * FROM students
    WHERE grade = "9"
    SQL
    Student.many_objects_from_db(sql)
  end

  def self.students_below_12th_grade
    sql = <<-SQL
    SELECT * FROM students
    WHERE grade != "12"
    SQL
    Student.many_objects_from_db(sql)
  end

  def self.first_X_students_in_grade_10(x)
    sql = <<-SQL
    SELECT * FROM students
    WHERE grade = "10"
    LIMIT ?
    SQL
    results = DB[:conn].execute(sql, x)
    results.map do |row|
      Student.new_from_db(row)
    end  
  end

  def self.first_student_in_grade_10
    sql = <<-SQL
    SELECT * FROM students
    WHERE grade = "10"
    LIMIT 1
    SQL
    student = DB[:conn].execute(sql)
    Student.new_from_db(student[0])
  end

  def self.all_students_in_grade_X(grade)
    sql = <<-SQL
    SELECT * FROM students
    WHERE grade = ?
    SQL
    results = DB[:conn].execute(sql, grade)
    results.map do |row|
      Student.new_from_db(row)
    end
  end

  
  def save
    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
end
