require 'doh/mysql/connector_instance'

module DohDb

@@cached_column_info = {}
def self.column_info(table, database = nil)
  database ||= DohDb::connector_instance.config[:database]
  lookup_str = database + '.' + table
  return @@cached_column_info[lookup_str] if @@cached_column_info[lookup_str]
  stmt = "SELECT column_name, is_nullable, data_type, character_maximum_length, numeric_scale, column_type FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='#{database}' AND TABLE_NAME='#{table}'"
  @@cached_column_info[lookup_str] = DohDb::select_transpose(stmt)
end

def self.field_character_size(table, field, database = nil)
  column_info(table, database).fetch(field, {}).fetch('character_maximum_length')
end

def self.chop_character_fields!(table, row)
  column_info(table).each do |field, attribs|
    maxlen = attribs['character_maximum_length']
    if maxlen && row[field].to_s.size > maxlen
      row[field] = row[field].to_s[0, maxlen]
    end
  end
  row
end

def self.chop_character_fields(table, row)
  chop_character_fields!(table, row.dup)
end

def self.field_exist?(table, field, database = nil)
  column_info(table, database).key?(field)
end

@@primary_keys = {}
def self.find_primary_key(table, database = nil)
  if table.index('.')
    database = table.before('.')
    table = table.after('.')
  else
    database ||= DohDb::connector_instance.config[:database]
  end

  dbhash = @@primary_keys[database]
  if dbhash.nil?
    dbhash = DohDb::select_transpose("SELECT table_name, column_name FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='#{database}' AND ORDINAL_POSITION=1")
    raise "no information found for database #{database}" if dbhash.empty?
    @@primary_keys[database] = dbhash
  end

  retval = dbhash[table]
  raise "attempting to find_primary_key for table that doesn't exist: #{database}.#{table}" if retval.nil?
  retval
end

def self.table_exist?(table, database = nil)
  !find_primary_key(table, database).nil?
end

def self.field_list(table, database = nil)
  column_info(table, database).keys
end

@@tables_by_database = {}
def self.all_tables(database = nil)
  database ||= DohDb::connector_instance.config[:database]
  @@tables_by_database[database] ||
    @@tables_by_database[database] ||= DohDb::select_list("SELECT table_name FROM information_schema.tables WHERE table_schema = '#{database}'")
end

end
