require 'sqlstmt/to_sql'
require 'mysql2'

class String
  undef to_sql
  def to_sql
    "'#{Mysql2::Client.escape(to_s)}'"
  end
end
