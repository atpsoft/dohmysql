require 'doh/mysql/to_sql'

module DohDb

class Test_to_sql < DohTest::TestGroup
  def test_stuff
    assert_equal("'blah'", 'blah'.to_sql)
  end
end

end

