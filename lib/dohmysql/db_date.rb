require 'dohutil/core_ext/datewithtime'

module DohDb

def self.today
  retval = Date.today
  def retval.to_sql
    'CURDATE()'
  end
  retval
end

def self.now
  retval = DateTime.zow
  def retval.to_sql
    'NOW()'
  end
  retval
end

end
