require 'mysql2'
require 'dohutil/array_to_hash'
require 'dohmysql/logger'
require 'dohmysql/error'
require 'dohmysql/typed_row_builder'
require 'dohmysql/writable_row'
require 'dohmysql/hash_row'
require 'dohmysql/smart_row'
require 'dohmysql/to_sql'
Mysql2::Client.default_query_options[:cast_booleans] = true
Mysql2::Client.default_query_options[:database_timezone] = :utc
Mysql2::Client.default_query_options[:application_timezone] = :utc

module DohDb

class Handle
  attr_reader :config, :mysqlh

  def initialize(config)
    @config = config.dup
    @testing_rollback = false
    @config[:reconnect] = true if !@config.keys.include?(:reconnect)
    @mysqlh = nil
    reopen
  end

  def close
    unless closed?
      begin
        DohDb.logger.call('connection', "closing connection: id #{@mysqlh.thread_id}")
        @mysqlh.close
      ensure
        @mysqlh = nil
      end
    end
  end

  def closed?
    @mysqlh.nil?
  end

  def query(statement)
    generic_query(statement)
    retval = @mysqlh.affected_rows
    DohDb.logger.call('result', "affected #{retval} rows")
    retval
  end

  def update(statement)
    generic_query(statement)
    retval = @mysqlh.affected_rows
    DohDb.logger.call('result', "updated #{retval} rows")
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
    DohDb.logger.call('result', "insert_id was #{retval}")
    retval
  end

  def insert_hash(hash, table, quote_strings = true)
    insert_hash_helper(hash, table, 'INSERT', quote_strings)
  end

  def insert_hashes(hashes, table, quote_strings = true)
    insert_hashes_helper(hashes, table, 'INSERT', quote_strings)
  end

  def insert_ignore_hash(hash, table, quote_strings = true)
    insert_hash_helper(hash, table, 'INSERT IGNORE', quote_strings)
  end

  def insert_ignore_hashes(hash, table, quote_strings = true)
    insert_hashes_helper(hash, table, 'INSERT IGNORE', quote_strings)
  end

  def replace_hash(hash, table, quote_strings = true)
    insert_hash_helper(hash, table, 'REPLACE', quote_strings)
  end

  def replace_hashes(hash, table, quote_strings = true)
    insert_hashes_helper(hash, table, 'REPLACE', quote_strings)
  end

  # The most generic form of select.
  # It calls to_s on the statement object to facilitate the use of sql builder objects.
  def select(statement, row_builder = nil)
    result_set = generic_query(statement)
    DohDb.logger.call('result', "selected #{result_set.size} rows")
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
      Doh.array_to_hash(rows) { |row| [row.at(0), row.at(1)] }
    else
      key_field = rows.first.keys.first
      Doh.array_to_hash(rows) do |row|
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

  def transaction
    query("START TRANSACTION")
    need_rollback = true
    begin
      retval = yield(self)
      if !@testing_rollback
        query("COMMIT")
        need_rollback = false
      end
    ensure
      reopen if need_rollback
    end
    retval
  end

  def test_transaction_rollback
    begin
      @testing_rollback = true
      yield(self)
    ensure
      @testing_rollback = false
    end
  end

  def start_select(statement, &block)
    @async_block = block
    sqlstr = statement.to_s
    DohDb.logger.call('query', "starting async select: #{sqlstr}")
    @mysqlh.query(sqlstr, :async => true)
  rescue Exception => excpt
    DohDb.logger.call('error', "caught exception #{excpt.message} starting aysnc query: #{sqlstr}", excpt)
    reopen
    raise
  end

  def finish_select
    result_set = @mysqlh.async_result
    DohDb.logger.call('result', "async selected #{result_set.size} rows")
    rows = get_row_builder.build_rows(result_set)
    rows.each do |dbrow|
      @async_block.call(dbrow)
    end
  end

private
  def generic_query(statement)
    sqlstr = statement.to_s
    DohDb.logger.call('query', sqlstr)
    @mysqlh.query(sqlstr)
  rescue Exception => excpt
    DohDb.logger.call('error', "caught exception #{excpt.message} during query: #{sqlstr}", excpt)
    reopen
    raise
  end

  def get_key_insert_str(keys)
    "(`#{keys.join('`,`')}`)"
  end

  def insert_hash_helper(hash, table, keyword, quote_strings)
    names = []
    values = []
    hash.each_pair do |key, value|
      names.push(key)
      values.push(if quote_strings || !value.is_a?(String) then value.to_sql else value end)
    end

    insert("#{keyword} INTO #{table} (`#{names.join('`,`')}`) VALUES (#{values.join(',')})")
  end

  def insert_hashes_helper(hashes, table, keyword, quote_strings)
    return if hashes.empty?

    valuestrs = []
    keys = hashes[0].keys
    keystr = get_key_insert_str(keys)
    hashes.each do |hash|
      values = []
      keys.each do |key|
        value = hash[key]
        values.push(if quote_strings || !value.is_a?(String) then value.to_sql else value end)
      end
      valuestrs.push("(#{values.join(',')})")
    end

    insert("#{keyword} INTO #{table} #{keystr} VALUES #{valuestrs.join(",")}")
  end

  def get_row_builder(row_builder = nil)
    if row_builder.nil?
      TypedRowBuilder.new
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

  def reopen
    close if !closed?
    log_config = @config.dup
    log_config.delete(:password)
    DohDb.logger.call('connection', "creating connection with config: #{log_config}")
    @mysqlh = Mysql2::Client.new(@config)
    DohDb.logger.call('connection', "new connection created: id #{@mysqlh.thread_id}")
  end
end

end
