require 'dohutil/current_date'
require 'dohmysql/db_date'

module DohDb

def self.current_date
  Doh.current_date(DohDb.today)
end

def self.current_datetime
  Doh.current_datetime(DohDb.now)
end

end
