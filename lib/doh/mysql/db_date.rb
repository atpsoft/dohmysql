require 'doh/core_ext/utc'

module DohDb

def self.today
  retval = Date.utcday
  def retval.to_sql
    'CURDATE()'
  end
  retval
end

def self.now
  retval = DateTime.utcnow
  def retval.to_sql
    'NOW()'
  end
  retval
end

end
