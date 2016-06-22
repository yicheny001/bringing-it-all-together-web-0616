# require 'pry'
class Dog
  # sql = "DROP TABLE IF EXISTS dogs"
  attr_accessor :name,:id,:breed

  def initialize(attributes_hash)
    @id = attributes_hash[:id]
    @name = attributes_hash[:name]
    @breed = attributes_hash[:breed]
    # @name = attributes_hash[:name]
    # @breed = attributes_hash[:breed]
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.udpate
    else
      sql = <<-SQL
        INSERT INTO dogs(name, breed)
        VALUES (?,?)
      SQL

      DB[:conn].execute(sql,self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end



  def self.create(attributes_hash)
    new_dog = Dog.new(attributes_hash)
    new_dog.save
    new_dog
  end

  def self.new_from_db(attributes_hash)
    new_dog = self.new({id:attributes_hash[0], name:attributes_hash[1], breed:attributes_hash[2]})
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * 
      FROM dogs 
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, id).map do |attributes_hash|
      self.new_from_db(attributes_hash)
    end.first
  end

    def self.find_by_name(name)
    sql = <<-SQL
      SELECT * 
      FROM dogs 
      WHERE name = ?
    SQL
    DB[:conn].execute(sql, name).map do |attributes_hash|
      self.new_from_db(attributes_hash)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    #(attributes_hash)
    
    # sql = <<-SQL
    #   SELECT * 
    #   FROM dogs 
    #   WHERE name = ? 
    #   AND breed = ?
    # SQL
    # dog = DB[:conn].execute(sql, attributes_hash[:name],attributes_hash[:breed]).map do |attributes_hash|
    #   self.new_from_db(attributes_hash)
    # # if !dog.empty?
    # #   Dog.create(attributes_hash)
    # # else
    # #   Dog.find_by_name(attributes_hash[:name])
    # end
    # dog

    sql = <<-SQL
      SELECT * 
      FROM dogs 
      WHERE name = ? 
      AND breed = ?
    SQL
    dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new({id:dog_data[0], name:dog_data[1], breed:dog_data[2]})
      
      # binding.pry
    else
      dog = self.create(name:name, breed:breed)
    end
    dog

  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, 
      breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name,self.breed, self.id)
  end
end
