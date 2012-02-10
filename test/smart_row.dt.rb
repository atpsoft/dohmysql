require 'doh/mysql/smart_row'

module DohDb

class Test_SmartRow < DohTest::TestGroup
  def test_display
    row = SmartRow.new(['flag'], [true])
    assert_equal('', row.display('this_field_doesnt_exist'))
    assert_raises(RuntimeError) { row.display.this_field_doesnt_exist }
    assert_equal('yes', row.display('flag'))
    assert_equal('yes', row.display.flag)
    row2 = row.dup
    assert_equal(true, row2.flag)
    row2.flag = false
    assert_equal(false, row2.flag)
    assert_equal(true, row.flag)
    assert_raises(RuntimeError) { row.this_field_doesnt_exist }
  end
end

end
