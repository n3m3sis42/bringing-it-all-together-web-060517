class Dog
  attr_accessor :name
  attr_reader :id, :breed

  def initialize(attributes_hash, id=nil)
    @id = id
    @name = attributes_hash[:name]
    @breed = attributes_hash[:breed]
  end

  def self.db
    DB[:conn]
  end

  def self.create_table
    sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT)
        SQL
    db.execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
        DROP TABLE dogs
      SQL
    db.execute(sql)
  end

  def save
    sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
    self.class.db.execute(sql, self.name, self.breed)
    @id = self.class.db.execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes_hash)
    self.new(attributes_hash).save
  end

  def self.new_from_db(row)
    self.new({name: row[1], breed: row[2]}, row[0])
  end

  def self.find_by_id(id)
    sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
      SQL
    new_from_db(db.execute(sql, id).first)
  end

  def self.find_by(attributes_hash)
    sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ?
      SQL
    db.execute(sql, attributes_hash[:name], attributes_hash[:breed]).first
  end

  def self.find_or_create_by(attributes_hash)
    record = find_by(attributes_hash)
    !record.nil? ? new_from_db(record) : create(attributes_hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
      SQL
    new_from_db(db.execute(sql, name).first)
  end

  def update
    sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
      SQL
    self.class.db.execute(sql, self.name, self.breed, self.id)
  end

end
