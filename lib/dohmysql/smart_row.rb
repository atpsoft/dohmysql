require 'dohmysql/abstract_row'

module DohDb

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

end
