require 'dohmysql/readonly_row'

module DohDb

class Test_ReadOnlyRow < DohTest::TestGroup
  def before_each
    @row = ReadOnlyRow.new(['id', 'fname', 'lname', 'other', 'flag', 'emptystr'], [3, 'george', 'bob', nil, true, ''])
  end

  def test_keys
    assert_equal(['id', 'fname', 'lname', 'other', 'flag', 'emptystr'], @row.keys)
  end

  def test_at_bad
    assert_raises(TypeError) {@row.at(nil)}
    assert_raises(TypeError) {@row.at('id')}
    assert_equal(nil, @row.at(8))
    assert_equal(nil, @row.at(-10))
  end

  def test_bracket_get_bad
    assert_equal(nil, @row[nil])
    assert_equal(nil, @row['blee'])
    assert_equal(nil, @row[8])
    assert_equal(nil, @row[-10])
  end

  def test_bracket_get_valid
    assert_equal(3, @row['id'])
    assert_equal('george', @row['fname'])
    assert_equal('bob', @row['lname'])
    assert_equal(nil, @row['other'])
  end

  def test_key_exists_bad
    assert_equal(false, @row.key?(nil))
    assert_equal(false, @row.key?('blee'))
    assert_equal(false, @row.key?(8))
    assert_equal(false, @row.key?(-10))
    assert_equal(false, @row.key?(-10))
  end

  def test_key_exists_valid
    assert_equal(true, @row.key?('id'))
    assert_equal(true, @row.key?('fname'))
    assert_equal(true, @row.key?('lname'))
    assert_equal(true, @row.key?('other'))
  end

  def test_to_a
    ary = @row.to_a
    assert_equal(6, ary.size)
    assert_equal(['id', 3], ary.at(0))
    assert_equal(['fname','george'], ary.at(1))
    assert_equal(['lname', 'bob'], ary.at(2))
    assert_equal(['other', nil], ary.at(3))
    assert_equal(['flag', true], ary.at(4))
    assert_equal(['emptystr', ''], ary.at(5))
  end

  def test_to_h
    hsh = @row.to_h
    assert_equal(6, hsh.size)
    assert_equal(3, hsh['id'])
    assert_equal('george', hsh['fname'])
    assert_equal('bob', hsh['lname'])
    assert_equal(nil, hsh['other'])
  end

  def test_method_missing
    assert_equal('george', @row.fname)
    assert_equal('bob', @row.lname)
    assert_equal(nil, @row.other)
    assert_raises(RuntimeError) {@row.this_field_doesnt_exist}
  end

  def test_empty_field
    assert(!@row.empty_field?('id'))
    assert(@row.empty_field?('other'))
    assert(@row.empty_field?('emptystr'))
    assert(@row.empty_field?('unknown_field_name'))
  end
end

end
