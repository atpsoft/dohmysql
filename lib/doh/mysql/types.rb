module DohDb

@@column_types = {}
def self.register_column_type(database, table, column, klass)
  database = '__global__' # until database support is available
  @@column_types[database] ||= {}
  table = '__global__' if table.nil?
  @@column_types[database][table] ||= {}
  @@column_types[database][table][column] = klass
end

def self.find_column_type(database, table, column)
  database = '__global__' # until database support is available
  db_hash = @@column_types[database]; return nil unless db_hash
  table = '__global__' if table.nil?
  table_hash = db_hash[table]; return nil unless table_hash
  table_hash[column]
end

def self.link_database_types(dest_db, source_db)
  @@column_types[dest_db] = @@column_types[source_db]
end

@@row_types = {}
def self.register_row_type(table, klass)
  @@row_types[table] = klass
end

def self.find_row_type(table)
  @@row_types[table]
end

end
