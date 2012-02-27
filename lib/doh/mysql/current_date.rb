require 'doh/current_date'
require 'doh/mysql/db_date'
require 'doh/mysql/parse'
require 'doh/mysql/to_sql'

module DohDb

def self.current_date_db
  Doh::current_date(DohDb::today)
end

def self.current_datetime_db
  Doh::current_datetime(DohDb::now)
end

def self.server_datetime
  retval = DohDb::select_field("SELECT #{DohDb::current_datetime_db.to_sql}")
  # if there is a fake datetime right now, will need to parse it
  retval = DohDb::parse_datetime(retval) if retval.is_a?(String)
  retval
end

end
