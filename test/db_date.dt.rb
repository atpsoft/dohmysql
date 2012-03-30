require 'doh/mysql/db_date'
require 'doh/mysql/to_sql'

module DohDb

class Test_db_date < DohTest::TestGroup
  def test_stuff
    assert_equal('CURDATE()', DohDb.today.to_sql)
    assert_equal('NOW()', DohDb.now.to_sql)
  end
end

end

