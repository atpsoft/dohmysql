require 'doh/mysql/writable_row'

module DohDb

class Test_WritableRow < DohTest::TestGroup
  def test_bracket_assign_not_mutate
    keys = []; values = []
    row = WritableRow.new(keys, values)
    keys.push('blah')
    values.push('blee')
    assert(row.keys.empty?)
    assert(row.values.empty?)
    row['frog'] = 'chicken'
    assert_equal(['blah'], keys)
    assert_equal(['blee'], values)
    assert_equal(['frog'], row.keys)
    assert_equal(['chicken'], row.values)
  end
end

end
