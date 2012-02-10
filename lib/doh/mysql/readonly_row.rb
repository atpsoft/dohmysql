require 'doh/mysql/abstract_row'

module DohDb

class ReadOnlyRow < AbstractRow
  # can accept 2 arguments: keys array, values array
  # or 1 argument: a hash
  def initialize(*args)
    keys, values = parse_initialize_args(*args)
    @keys = keys.freeze
    @values = values.freeze
    freeze
  end

  def method_missing(sym, *ignore)
    key = sym.to_s
    index = @keys.index(key)
    if index
      @values.at(index)
    else
      raise RuntimeError.new("unknown field: " + key)
    end
  end
end

end
