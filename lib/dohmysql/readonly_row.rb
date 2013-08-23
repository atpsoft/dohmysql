require 'dohmysql/abstract_row'

module DohDb

class ReadOnlyRow < AbstractRow
  # can accept 2 arguments: keys array, values array
  # or 1 argument: a hash
  def initialize(*args)
    parsed_args = parse_initialize_args(*args)
    if parsed_args.size == 3
      @table = parsed_args.pop
    end
    keys, values = parsed_args
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
