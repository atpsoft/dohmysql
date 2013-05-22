module DohDb

class HashRow
  def self.new(keys, values)
    hash = {}
    keys.each_with_index do |key, index|
      hash[key] = values.at(index)
    end
    hash
  end
end

end
