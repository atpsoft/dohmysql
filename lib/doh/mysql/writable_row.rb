require 'doh/core_ext/string'
require 'doh/mysql/abstract_row'
require 'set'

module DohDb

class WritableRow < AbstractRow
  attr_reader :changed_keys

  # can accept 2 arguments: keys array, values array
  # or 1 argument: a hash
  def initialize(*args)
    keys, values = parse_initialize_args(*args)
    @keys = keys.dup
    @values = values.dup
    @changed_keys = Set.new
  end

  def initialize_copy(orig)
    super(orig)
    @changed_keys = Set.new
  end

  def set(key, value)
    index = @keys.index(key)
    if index
      @values[index] = value
    else
      @keys.push(key)
      @values.push(value)
    end
    @changed_keys.add(key)
    value
  end
  alias []= set

  def clear_changed_keys
    @changed_keys.clear
  end

  def method_missing(sym, *args)
    name = sym.to_s
    if name.lastn(1) == '='
      key = name[0..-2]
      assign = true
    else
      key = name
    end
    raise RuntimeError.new("unknown field: " + name) unless key?(key)

    if assign
      set(key, args.first)
    else
      get(key)
    end
  end
end

end
