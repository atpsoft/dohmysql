require 'doh/mysql/writable_row'
require 'doh/to_display'
require 'sqlstmt/update'

module DohDb

class RowDisplayProxy
  def initialize(row)
    @row = row
  end

  def method_missing(sym, *ignore_args)
    @row.send(sym.to_s).to_display
  end
end

class AbstractSmartRow < AbstractRow
  attr_accessor :table
  attr_reader :changed_keys

  def initialize(keys, values)
    @keys = keys.dup
    @values = values.dup
    @changed_keys = Set.new
  end

  def initialize_copy(orig)
    @keys = @keys.dup
    @values = @values.dup
    @changed_keys = @changed_keys.dup
    @display_proxy = nil
  end

  def display(key = nil)
    if key.nil?
      @display_proxy ||= RowDisplayProxy.new(self)
    else
      get(key).to_display
    end
  end

  def set(key, value, flag_changed = true)
    index = @keys.index(key)
    if index
      if @values[index] != value
        @values[index] = value
        @changed_keys.add(key)
      end
    else
      @keys.push(key)
      @values.push(value)
      @changed_keys.add(key)
    end
    value
  end
  alias []= set

  def clear_changed_keys
    @changed_keys.clear
  end

  def method_missing(sym, *args)
    name = sym.to_s
    if name.end_with?('=')
      guess_missing_set(name[0..-2], args.first)
    else
      guess_missing_get(name)
    end
  end

  def merge!(hash)
    hash.each_pair { |key, value| set(key, value) }
  end

  def delete(key)
    index = @keys.index(key)
    return unless index
    @keys.delete_at(index)
    @values.delete_at(index)
  end

  def db_insert
    newid = DohDb::insert_hash(self, @table)
    if newid != 0
      set(primary_key, newid, false)
    end
    newid
  end

  def db_update
    return if @changed_keys.empty?
    before_db_update
    builder = SqlStmt::Update.new.table(@table)
    builder.where("#{primary_key} = #{get(primary_key).to_sql}")
    @changed_keys.each {|key| builder.field(key, get(key).to_sql)}
    DohDb::query(builder)
    after_db_update
    @changed_keys.clear
  end

protected
  def primary_key
    DohDb::find_primary_key(@table)
  end

  def before_db_update
  end

  def after_db_update
  end

  def guess_missing_get(key)
    return get(key) if key?(key)
    raise "unknown field: #{key}"
  end

  def guess_missing_set(key, value)
    set(key, value)
  end
end

class SmartRow < AbstractSmartRow
  def initialize(*args)
    parsed_args = parse_initialize_args(*args)
    if parsed_args.size == 3
      @table = parsed_args.pop
    end
    super(*parsed_args)
  end
end

class CustomSmartRow < AbstractSmartRow
  def initialize(*args)
    super(*parse_initialize_args(*args))
    @table = self.class.default_table
  end
end

end
