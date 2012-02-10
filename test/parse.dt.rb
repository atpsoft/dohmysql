require 'doh/mysql/parse'

module DohDb

class Test_Parse < DohTest::TestGroup
  def test_bool
    assert_equal(false, DohDb::parse_bool('0'))
    assert_equal(true, DohDb::parse_bool('1'))
    assert_raises(ArgumentError) {DohDb::parse_bool('blah')}
  end

  def test_date
    assert_raises(ArgumentError) {DohDb::parse_date('blah')}
    assert_equal(Date.new(2008,2,14), DohDb::parse_date('2008-02-14'))
    assert_raises(ArgumentError) {DohDb::parse_date('20080214')}
    assert_not_equal(Date.new(2008,2,14), DohDb::parse_date('2008-02-15'))
    assert_equal(nil, DohDb::parse_date('0000-00-00'))
  end

  def test_datetime
    assert_raises(ArgumentError) {DohDb::parse_date('blah')}
    assert_raises(ArgumentError) {DohDb::parse_datetime('zzzzzzzzzzzzzzzzzzz')}
    assert_equal(DateTime.new(2008,2,14,10,20,30), DohDb::parse_datetime('2008-02-14 10:20:30'))
    assert_not_equal(DateTime.new(2008,2,14,10,20,30), DohDb::parse_datetime('2008-02-14 10:20:31'))
    assert_equal(nil, DohDb::parse_datetime('0000-00-00 00:00:00'))
  end

  def test_decimal
    assert_equal(BigDecimal.new('3.14'), DohDb::parse_decimal('3.14'))
    assert_equal(BigDecimal.new('0.0'), DohDb::parse_decimal('sjdkflsdjl'))
  end

  def test_int
    assert_equal(3, DohDb::parse_int('3'))
    assert_equal(0, DohDb::parse_int('sjdkflsdjl'))
  end
end

end
