require 'doh/mysql/metadata_util'
require 'doh/mysql/error'

module DohDb

def self.convert(table, column, value)
  info = column_info(table)[column]
  return value if info.nil?
  if value.nil?
    raise CannotBeNull, "#{table}.#{column}" if info['is_nullable'] == 'NO'
    return nil
  end
  return nil if value.is_a?(String) && value.empty? && info['is_nullable'] == 'YES'
  value
end

end
