module DohDb

def self.set_connector_instance(conn)
  @@connector_instance = conn
end

def self.connector_instance
  @@connector_instance
end

def self.request_handle
  connector_instance.request_handle
end

def self.query(statement)
  request_handle.query(statement)
end

def self.update(statement)
  request_handle.update(statement)
end

def self.update_row(statement)
  request_handle.update_row(statement)
end

def self.update_hash(hash, table, primary_key_value, primary_key_name)
  request_handle.update_hash(hash, table, primary_key_value, primary_key_name)
end

def self.insert(statement)
  request_handle.insert(statement)
end

def self.insert_hash(hash, table, quote_strings = true)
  request_handle.insert_hash(hash, table, quote_strings)
end

def self.insert_ignore_hash(hash, table, quote_strings = true)
  request_handle.insert_ignore_hash(hash, table, quote_strings)
end

def self.replace_hash(hash, table, quote_strings = true)
  request_handle.replace_hash(hash, table, quote_strings)
end

def self.select(statement, row_builder = nil)
  request_handle.select(statement, row_builder)
end

def self.select_row(statement, row_builder = nil)
  request_handle.select_row(statement, row_builder)
end

def self.select_optional_row(statement, row_builder = nil)
  request_handle.select_optional_row(statement, row_builder)
end

def self.select_field(statement, row_builder = nil)
  request_handle.select_field(statement, row_builder)
end

def self.select_optional_field(statement, row_builder = nil)
  request_handle.select_optional_field(statement, row_builder)
end

def self.select_transpose(statement, row_builder = nil)
  request_handle.select_transpose(statement, row_builder)
end

def self.select_values(statement, row_builder = nil)
  request_handle.select_values(statement, row_builder)
end

def self.select_list(statement, row_builder = nil)
  request_handle.select_list(statement, row_builder)
end

def self.multi_select(statements)
  request_handle.multi_select(statements)
end

end
