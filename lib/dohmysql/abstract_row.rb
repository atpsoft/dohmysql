require 'dohutil/core_ext/force_deep_copy'

module DohDb

class AbstractRow
  attr_accessor :keys, :values
  force_deep_copy :keys, :values

  def at(index)
    @values.at(index)
  end

  def get(key)
    index = @keys.index(key)
    if index
      @values.at(index)
    else
      nil
    end
  end
  alias [] get

  def key?(key)
    !@keys.index(key).nil?
  end

  def to_a
    retval = []
    @keys.size.times {|index| retval.push([@keys[index], @values[index]])}
    retval
  end
  alias to_ary to_a

  def to_h
    retval = {}
    @keys.each_with_index {|key, index| retval[key] = @values.at(index)}
    retval
  end

  def inspect
    ary = []
    @keys.size.times {|index| ary.push([@keys[index], @values[index]])}
    ary.inspect
  end

  def each_pair
    @keys.size.times do |index|
      yield(@keys.at(index), @values.at(index))
    end
  end

  def size
    @keys.size
  end

  def empty_field?(key)
    return true if !key?(key)
    val = get(key)
    return val.nil? || (val.respond_to?(:empty?) && val.empty?)
  end

protected
  def parse_initialize_args(*args)
    if args.empty?
      [[], []]
    elsif args[0].is_a?(Array)
      raise "first arg is array, second must be also" unless args[1].is_a?(Array)
      raise "first two args are arrays, must be of the same size" unless args[0].size == args[1].size
      args
    else
      hash = args[0]
      [hash.keys, hash.values] + args[1..-1]
    end
  end
end

end
