require 'doh/mysql/unquoted'

module DohDb

class Test_Unquoted < DohTest::TestGroup
  def test_stuff
    assert_equal('', Unquoted.new)
    assert_equal('blah', Unquoted.new('blah'))
    assert_equal('blah', Unquoted.new('blah').to_s)
    assert_equal('blah', Unquoted.new('blah').to_sql)
    assert_equal('SELECT * FROM blah WHERE smoe = NULL', "SELECT * FROM blah WHERE smoe = #{DohDb::NULL.to_sql}")
  end
end

end

