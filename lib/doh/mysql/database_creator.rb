require 'doh/core_ext/dir'
require 'doh/mysql/handle'
require 'doh/mysql/load_sql'
require 'doh/mysql/version'
require 'doh/mysql/types'

module DohDb

class DatabaseCreator
  def initialize(data_directory = nil, connector = nil)
    @data_directory = data_directory || File.join(Doh::root, 'database')
    @connector = connector || DohDb::connector_instance
    @include_scripts = true
  end

  def create_database(dbname, drop_first = false)
    create_one_database(get_nodb_handle, dbname, dbname, drop_first)
  end

  def create_database_copy(dest_db, source_db, drop_first = false)
    create_one_database(get_nodb_handle, dest_db, source_db, drop_first)
  end

  def create_all_databases(drop_first = false)
    dbh = get_nodb_handle
    Dir.directories(@data_directory).each {|elem| create_one_database(dbh, elem, elem, drop_first)}
  end

  def create_tables(database, drop_first, *table_and_view_names)
    @connector.database = database
    views, tables = table_and_view_names.flatten.sort.partition {|name| File.exist?(sql_filename(database, 'views', name))}
    tables.each {|name| create_base_table(database, name, drop_first)}
    views.each {|name| create_view(database, name, drop_first)}
  end

  def exclude_scripts
    @include_scripts = false
    self
  end

private
  def get_nodb_handle
    @connector.reset
    @connector.database = ''
    @connector.request_handle
  end

  def sql_filename(database, subdir, name)
    File.join(@data_directory, database, subdir, name) + '.sql'
  end

  def find_files(source_db, subdir, ext = '.sql')
    path = File.join(@data_directory, source_db, subdir)
    return [] unless File.exist?(path)
    Dir.entries(path).find_all {|entry| entry.end_with?(ext)}.sort.collect {|elem| File.join(path, elem)}
  end

  def view_files(source_db)
    path = File.join(@data_directory, source_db, 'views')
    return [] unless File.exist?(path)
    ordered_filenames = YAML.load_file(File.join(path, 'order.yml')).collect {|uqfn| File.join(path, uqfn) + '.sql'}
    ordered_filenames + (find_files(source_db, 'views') - ordered_filenames)
  end

  def create_base_table(database, table_name, drop_first)
    DohDb::query("DROP TABLE IF EXISTS #{table_name}") if drop_first
    files = [sql_filename(database, 'tables', table_name)]
    inserts_file = sql_filename(database, 'insert_sql', table_name)
    files.push(inserts_file) if File.exist?(inserts_file)
    DohDb::load_sql_connector(files, DohDb::connector_instance)
  end

  def create_view(database, view_name, drop_first)
    DohDb::query("DROP VIEW IF EXISTS #{view_name}") if drop_first
    DohDb::load_sql_connector([sql_filename(database, 'views', view_name)], DohDb::connector_instance)
  end

  def create_one_database(dbh, dest_db, source_db, drop_first)
    dohlog.info("creating database " + dest_db + " from source files at " + File.join(@data_directory, source_db))
    dbh.query("DROP DATABASE IF EXISTS " + dest_db) if drop_first

    dbh.query("CREATE DATABASE " + dest_db)
    dbh.query("USE " + dest_db)
    dbh.query("CREATE TABLE version (version INT UNSIGNED NOT NULL) ENGINE=MyISAM")
    dbver = DohDb::latest_database_version(source_db)
    dbh.query("INSERT INTO version VALUES (#{dbver})")

    @connector.database = dest_db

    files = find_files(source_db, 'tables') + find_files(source_db, 'insert_sql') + view_files(source_db)
    DohDb::load_sql_connector(files, @connector, dest_db)
    return unless @include_scripts
    find_files(source_db, 'insert_scripts', '.rb').each do |filename|
      dohlog.info("loading file: #{filename}")
      load(filename)
    end
  end
end

end
