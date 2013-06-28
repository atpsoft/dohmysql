require 'dohutil/core_ext/dir'
require 'dohmysql/handle'
require 'dohmysql/load_sql'
require 'yaml'
require 'dohmysql/file_util'

module DohDb

class DatabaseCreator
  MIGRATE_TABLE_DEF = "CREATE TABLE migrate (migrated_at DATETIME NOT NULL, name CHAR(50) NOT NULL, sql_applied TEXT NOT NULL)"

  def initialize(sqlfiles_directory = nil, connector = nil)
    @sqlfiles_directory = sqlfiles_directory || DohDb.sql_files_path
    @connector = connector || DohDb.connector_instance
    @include_scripts = true
  end

  def create_database(dbname, drop_first, include_migrates)
    create_one_database(get_handle(''), dbname, dbname, drop_first, include_migrates)
  end

  def create_database_copy(dest_db, source_db, drop_first, include_migrates)
    create_one_database(get_handle(''), dest_db, source_db, drop_first, include_migrates)
  end

  def create_all_databases(drop_first, include_migrates)
    dbh = get_handle('')
    Dir.directories(@sqlfiles_directory).each {|elem| create_one_database(dbh, elem, elem, drop_first, include_migrates)}
  end

  def create_tables(database, drop_first, *table_and_view_names)
    dbh = get_handle(database)
    views, tables = table_and_view_names.flatten.sort.partition {|name| File.exist?(sql_filename(database, 'views', name))}
    tables.each {|name| create_base_table(dbh, database, name, drop_first)}
    views.each {|name| create_view(dbh, database, name, drop_first)}
  end

  def exclude_scripts
    @include_scripts = false
    self
  end

private
  def get_handle(database)
    @connector.reset
    @connector.config[:database] = database
    @connector.request_handle
  end

  def sql_filename(database, subdir, name)
    File.join(@sqlfiles_directory, database, subdir, name) + '.sql'
  end

  def find_files(glob)
    Dir.glob(File.join(@sqlfiles_directory, glob)).sort
  end

  def view_files(source_db)
    path = File.join(@sqlfiles_directory, source_db, 'views')
    return [] unless File.exist?(path)
    ordered_filenames = YAML.load_file(File.join(path, 'order.yml')).collect {|uqfn| File.join(path, uqfn) + '.sql'}
    ordered_filenames + (find_files("#{source_db}/views/*.sql") - ordered_filenames)
  end

  def create_base_table(dbh, database, table_name, drop_first)
    dbh.query("DROP TABLE IF EXISTS #{table_name}") if drop_first
    files = [sql_filename(database, 'tables', table_name)]
    inserts_file = sql_filename(database, 'inserts', table_name)
    files.push(inserts_file) if File.exist?(inserts_file)
    load_sql(dbh, files)
  end

  def create_view(dbh, database, view_name, drop_first)
    dbh.query("DROP VIEW IF EXISTS #{view_name}") if drop_first
    load_sql(dbh, [sql_filename(database, 'views', view_name)])
  end

  def create_one_database(dbh, dest_db, source_db, drop_first, include_migrates)
    dohlog.info("creating database " + dest_db + " from source files at " + File.join(@sqlfiles_directory, source_db))
    dbh.query("DROP DATABASE IF EXISTS " + dest_db) if drop_first

    dbh.query("CREATE DATABASE " + dest_db)
    dbh.query("USE " + dest_db)
    dbh.query(MIGRATE_TABLE_DEF)

    @connector.config[:database] = dest_db
    dbh.config[:database] = dest_db

    files = find_files("#{source_db}/tables/*.sql") + find_files("#{source_db}/inserts/*.sql") + view_files(source_db)
    load_sql(dbh, files)
    run_scripts(source_db) if @include_scripts
    apply_migrates(dbh, source_db) if include_migrates
  end

  def load_sql(dbh, files)
    DohDb.load_sql_using_each_open3(@connector.config, files)
    # files.each do |filename|
    #   contents = File.read(filename)
    #   queries = contents.split(/;$/)
    #   queries.each do |str|
    #     str.strip!
    #     next if str.empty?
    #     dbh.query(str)
    #   end
    # end
  end

  def apply_migrates(dbh, source_db)
    apply_files = find_files("#{source_db}/migrate/*_apply.sql")
    load_sql(dbh, apply_files)
    apply_files.each do |path|
      migrate_name = File.basename(path).slice(0..-11)
      contents = File.open(path) {|file| file.read}
      dbh.query("INSERT INTO migrate SET migrated_at = NOW(), name = #{migrate_name.to_sql}, sql_applied = #{contents.to_sql}")
    end
  end

  def run_scripts(source_db)
    find_files("#{source_db}/scripts/*.rb").each do |filename|
      dohlog.info("loading file: #{filename}")
      load(filename)
    end
  end
end

end
