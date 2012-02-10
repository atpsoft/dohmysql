module DohDb

class Unquoted < String
  def to_sql
    to_s
  end
end

def self.unquoted(str)
  Unquoted.new(str)
end

NOW = Unquoted.new('NOW()').freeze
TODAY = Unquoted.new('CURDATE()').freeze
NULL = Unquoted.new('NULL').freeze

end
