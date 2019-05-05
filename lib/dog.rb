#require_relative "../config/environment.rb"

class Dog
  attr_accessor :name
  attr_reader :id, :breed

  def initialize (name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql =  <<-SQL
        DROP TABLE dogs
        SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

       DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
     end
     self
  end

  def self.create(name:, breed:)
    dogs = Dog.new(name: name, breed: breed)
    dogs.save
    dogs
  end

  def self.find_by_id(num)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

     row = DB[:conn].execute(sql, num)[0]
    self.new(id: row[0], name: row[1], breed: row[2])
  end
  def self.new_from_db(row)
       self.new(id: row[0], name: row[1], breed: row[2])
     end

      def self.find_by_name(name)
       sql = <<-SQL
       SELECT * FROM dogs WHERE name = ? LIMIT 1
       SQL
       DB[:conn].execute(sql, name).map do |row|
       self.new_from_db(row)
     end.first
   end

       def update
     sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
     DB[:conn].execute(sql, self.name, self.breed, self.id)
   end

    def self.find_or_create_by(name:, breed:)
   sql = <<-SQL
       SELECT *
       FROM dogs
       WHERE name = ? AND breed = ?;
     SQL

      dog_from_db = DB[:conn].execute(sql, name, breed)

      if dog_from_db.empty?
       self.create(name: name, breed: breed)
     else
       dog_data = dog_from_db[0]
       self.find_by_id(dog_data[0])
     end
   end

  end
