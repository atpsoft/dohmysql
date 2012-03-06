require 'doh/array_to_hash'
require 'doh/log/stub'
require 'doh/mysql/error'
require 'doh/mysql/typed_row_builder'
require 'doh/mysql/writable_row'
require 'doh/mysql/hash_row'
require 'doh/mysql/smart_row'
require 'doh/mysql/to_sql'

module DohDb

class Handle
  def initialize(mysqlh, row_builder = nil)
    @mysqlh = mysqlh
    @row_builder = row_builder || TypedRowBuilder.new
  end

  def close
    unless closed?
      dohlog.info("closing raw mysql handle: #@mysqlh")
      @mysqlh.close
      @mysqlh = nil
    end
  end

  def closed?
    @mysqlh.nil?
  end

  def query(statement)
    generic_query(statement)
    retval = @mysqlh.affected_rows
    dohlog.info("affected #{retval} rows")
    retval
  end

  def update(statement)
    generic_query(statement)
    retval = @mysqlh.affected_rows
    dohlog.info("updated #{retval} rows")
    retval
  end

  def update_row(statement)
    retval = update(statement)
    raise UnexpectedQueryResult, "updated #{retval} rows; expected 1" unless retval == 1
    retval
  end

  def update_hash(hash, table, primary_key_value, primary_key_name)
    items = hash.keys.collect {|key| key + ' = ' + hash[key].to_sql}
    query("UPDATE #{table} SET #{items.join(', ')} WHERE #{primary_key_name} = #{primary_key_value.to_sql}")
  end

  def insert(statement)
    generic_query(statement)
    retval = @mysqlh.last_id
    dohlog.info("insert_id was #{retval}")
    retval
  end

  def insert_hash(hash, table, quote_strings = true)
    insert_hash_helper(hash, table, 'INSERT', quote_strings)
  end

  def insert_ignore_hash(hash, table, quote_strings = true)
    insert_hash_helper(hash, table, 'INSERT IGNORE', quote_strings)
  end

  def replace_hash(hash, table, quote_strings = true)
    insert_hash_helper(hash, table, 'REPLACE', quote_strings)
  end

  # The most generic form of select.
  # It calls to_s on the statement object to facilitate the use of sql builder objects.
  def select(statement, row_builder = nil)
    result_set = generic_query(statement)
    dohlog.info("selected #{result_set.size} rows")
    rows = get_row_builder(row_builder).build_rows(result_set)
    rows
  end

  # Simple convenience wrapper around the generic select call.
  # Throws an exception unless the result set is a single row.
  # Returns the row selected.
  def select_row(statement, row_builder = nil)
    rows = select(statement, row_builder)
    raise UnexpectedQueryResult, "selected #{rows.size} rows; expected 1" unless rows.size == 1
    rows[0]
  end

  # Simple convenience wrapper around the generic select call.
  # Throws an exception unless the result set is empty or a single row.
  # Returns nil if the result set is empty, or the row selected.
  def select_optional_row(statement, row_builder = nil)
    rows = select(statement, row_builder)
    raise UnexpectedQueryResult, "selected #{rows.size} rows; expected 0 or 1" if rows.size > 1
    if rows.empty? then nil else rows[0] end
  end

  # Simple convenience wrapper around select_row.
  # Returns the first (and typically, the only) field from the selected row.
  def select_field(statement, row_builder = nil)
    select_row(statement, row_builder).at(0)
  end

  # Simple convenience wrapper around select_optional_row.
  # Returns the first (and typically, the only) field from the selected row, if any, or nil.
  def select_optional_field(statement, row_builder = nil)
    row = select_optional_row(statement, row_builder)
    row && row.at(0)
  end

  # Rows in the result set must have 2 or more fields.
  # If there are 2 fields, returns a hash where each key is the first field in the result set, and the value is the second field.
  # If there are more than 2 fields, returns a hash where each key is the first field in the result set,
  # and the value is the row itself, as a Hash, and without the field used as a key.
  def select_transpose(statement, row_builder = nil)
    rows = select(statement, row_builder)
    return {} if rows.empty?
    field_count = rows.first.size
    if field_count < 2
      raise UnexpectedQueryResult, "must select at least 2 fields in order to transpose"
    elsif field_count == 2
      Doh::array_to_hash(rows) { |row| [row.at(0), row.at(1)] }
    else
      key_field = rows.first.keys.first
      Doh::array_to_hash(rows) do |row|
        value = row.to_h
        value.delete(key_field)
        [row.at(0), value]
      end
    end
  end

  # Returns an array of arrays, where the individual arrays contain just the values from each database row -- they lack field names.
  def select_values(statement, row_builder = nil)
    select(statement, row_builder).collect { |row| row.values }
  end

  # Returns an array of the first (and typically, the only) field of every row in the result set.
  def select_list(statement, row_builder = nil)
    select(statement, row_builder).collect { |row| row.at(0) }
  end

private
  def generic_query(statement)
    sqlstr = statement.to_s
    dohlog.info(sqlstr)
    @mysqlh.query(sqlstr)
  rescue Exception => excpt
    dohlog.error("caught exception during query: #{sqlstr}", excpt)
    raise
  end

  def insert_hash_helper(hash, table, keyword, quote_strings)
    names = []
    values = []
    hash.each_pair do |key, value|
      names.push(key)
      values.push(if quote_strings || !value.is_a?(String) then value.to_sql else value end)
    end

    insert("#{keyword} INTO #{table} (#{names.join(',')}) VALUES (#{values.join(',')})")
  end

  def get_row_builder(row_builder = nil)
    if row_builder.nil?
      @row_builder
    elsif row_builder == :read
      TypedRowBuilder.new(ReadOnlyRow)
    elsif row_builder == :hash
      TypedRowBuilder.new(HashRow)
    elsif row_builder == :write
      TypedRowBuilder.new(WritableRow)
    elsif row_builder == :smart
      TypedRowBuilder.new(SmartRow)
    elsif row_builder.respond_to?('build_rows')
      row_builder
    else
      TypedRowBuilder.new(row_builder)
    end
  end
end

end
