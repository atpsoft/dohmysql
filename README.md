DohMysql
========

DohMysql is a library for connecting to / querying a mysql database.  Here's an example:

``` ruby
require 'doh/mysql'
DohDb.set_connector_instance(DohDb::CacheConnector.new({:host => 'localhost', :username => 'username', :password => 'password', :database => 'testdb'}))
Doh.db.select("select * from example_table")
# [[["example_table_id", 1], ["example_field_1", "string row1 value"], ["date row1 value", #<DateTime object here>]], 
#  [["example_table_id", 2], ["example_field_1", "string row2 value"], ["date row2 value", #<DateTime object here>]]] 
```
