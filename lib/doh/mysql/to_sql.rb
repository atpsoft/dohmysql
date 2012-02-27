require 'sqlstmt/to_sql'
require 'mysql2'

class String
  def to_sql
    "'#{Mysql2::Client.escape(to_s)}'"
  end
end
