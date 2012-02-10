require 'doh/mysql/to_sql'

module DohDb

class Test_to_sql < DohTest::TestGroup
  def test_stuff
    assert_equal('"blah"', 'blah'.to_sql)
    assert_equal('NULL', nil.to_sql)
    assert_equal('3', 3.to_sql)
    assert_equal('"2008-09-24 09:30:04"', DateTime.new(2008,9,24,9,30,4).to_sql)
    assert_equal('1', true.to_sql)
    assert_equal('0', false.to_sql)
    assert_equal('10.0', BigDecimal.new('10').to_sql)
    assert_equal('("a","b","c")', ['a', 'b', 'c'].to_sql)
  end
end

end

