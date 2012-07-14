DohMysql
========

DohMysql is a library for connecting to / querying a mysql database.  Here's an example:

``` ruby
require 'doh/mysql'
DohDb.set_connector_instance(DohDb::CacheConnector.new({:host => 'localhost', :username => 'username', :password => 'password', :database => 'testdb'}))
rows = Doh.db.select("select * from example_table")
# [[["example_table_id", 1], ["string_field", "string row1 value"], ["date_field", #<DateTime row1 value here>]], 
#  [["example_table_id", 2], ["string_field", "string row2 value"], ["date_field", #<DateTime row2 value here>]]] 
puts rows[0]['example_table_id']
# 1
```
