require 'mysql'
require 'doh/mysql/parse'
require 'doh/to_display'
require 'doh/mysql/types'
require 'doh/core_ext/string'

module DohDb

class DefaultTypeGuesser
  # for compatibility with older mysql gems
  if !MysqlField.const_defined?('TYPE_NEWDECIMAL')
    MysqlField::TYPE_NEWDECIMAL = 246
  end
  DECIMAL_TYPES = [MysqlField::TYPE_DECIMAL, MysqlField::TYPE_NEWDECIMAL]
  INT_TYPES = [MysqlField::TYPE_TINY,MysqlField::TYPE_SHORT,MysqlField::TYPE_LONG,MysqlField::TYPE_LONGLONG,MysqlField::TYPE_INT24]

  def self.guess_type(value, meta)
    return nil if value.nil?

    custom_type = DohDb::find_column_type(nil, meta.table, meta.name) || DohDb::find_column_type(nil, nil, meta.name)
    return custom_type.build(meta.name, value) if custom_type

    return DohDb::parse_bool(value) if (meta.type == MysqlField::TYPE_TINY) && (meta.length == 1) && (meta.max_length == 1)
    return DohDb::parse_datetime(value) if meta.type == MysqlField::TYPE_DATETIME
    return DohDb::parse_date(value) if meta.type == MysqlField::TYPE_DATE
    return DohDb::parse_decimal(value) if DECIMAL_TYPES.include?(meta.type)
    return DohDb::parse_int(value) if INT_TYPES.include?(meta.type)
    if meta.type == MysqlField::TYPE_STRING || meta.type == MysqlField::TYPE_VAR_STRING
      return PhoneDisplayString.new(value) if (value.size == 10) && (meta.name.lastn(5) == 'phone')
      return SsnDisplayString.new(value) if (value.size == 9) && (meta.max_length == 9) && (meta.name.lastn(3) == 'ssn')
      return PostalDisplayString.new(value) if [5,9].include?(value.size) && [5,9].include?(meta.max_length) && ((meta.name.lastn(6) == 'postal') || (meta.name.lastn(3) == 'zip'))
    end
    value
  end
end

end
