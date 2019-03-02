require_relative "../config/environment.rb"

class Student
attr_reader :id
attr_accessor :name, :grade

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def self.create_table
    query = <<-SQL
    CREATE TABLE students (
    id INTEGER PRIMARY KEY,
    name STRING,
    grade INTEGER
    )
    SQL

    DB[:conn].execute(query)
  end

  def self.drop_table
    query = <<-SQL
    DROP TABLE students
    SQL

    DB[:conn].execute(query)
  end

  def save
    if @id
      update
    else
      query = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(query, name, grade)

      query = <<-SQL
      SELECT last_insert_rowid()
      FROM students
      SQL
      @id = DB[:conn].execute(query)[0][0]

    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    Student.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    query = <<-SQL
    SELECT *
    FROM students
    WHERE name = ?
    SQL
    DB[:conn].execute(query, name).map {|row| self.new_from_db(row)}.first
  end

  def update
    query = <<-SQL
    UPDATE students
    SET name = ?, grade = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(query, name, grade, id)
  end



end
