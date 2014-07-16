DohMysql
========

This gem is not currently under active development.  It will be reborn at a later time.

[![Build Status](https://travis-ci.org/atpsoft/dohmysql.png)](https://travis-ci.org/atpsoft/dohmysql)
[![Code Climate](https://codeclimate.com/github/atpsoft/dohmysql.png)](https://codeclimate.com/github/atpsoft/dohmysql)

DohMysql is a library for connecting to / querying a mysql database.  Here's an example:

``` ruby
require 'dohmysql'
DohDb.set_connector_instance(DohDb::CacheConnector.new({:host => 'localhost', :username => 'username', :password => 'password', :database => 'testdb'}))
rows = Doh.db.select("select * from example_table")
# [[["example_table_id", 1], ["string_field", "string row1 value"], ["date_field", #<DateTime row1 value here>]],
#  [["example_table_id", 2], ["string_field", "string row2 value"], ["date_field", #<DateTime row2 value here>]]]
puts rows[0]['example_table_id']
# 1
row = rows[0].to_h
# {"example_table_id"=>1, "string_field"=>"string row1 value", "date_field"=>#<DateTime row1 value here>}
row.delete('example_table_id')
row['string_field'] = 'string row3 value'
insert_id = Doh.db.insert_hash(row, 'example_table')
# 3
Doh.db.select("select * from example_table where example_table_id = #{insert_id}")
# [[["example_table_id", 3], ["string_field", "string row3 value"], ["date_field", #<DateTime row1 value here>]]]

```
