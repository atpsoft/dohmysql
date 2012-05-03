require 'doh/mysql/load_sql'

module DohDb

class MigrateRunner
  def initialize(database)
    @database = database
    @table = @database + '.migrate'
    @directory = File.join(DohDb.sql_files_path(@database), 'migrate')
    @config = DohDb::connector_instance.config
  end

  def make(migrate_name)
    apply_fname = apply_filename(migrate_name)
    if File.exist?(apply_fname)
      return [false, "it appears that migration #{migrate_name} already exists"]
    end
    `touch #{apply_fname}`
    `touch #{revert_filename(migrate_name)}`
    [true, "files for migration #{migrate_name} created in #{@directory}"]
  end

  def apply(migrate_name)
    if migrate_exist?(migrate_name)
      return [false, "migration #{migrate_name} has already been applied"]
    end
    fname = apply_filename(migrate_name)
    load_sql(fname)
    contents = File.open(fname) {|file| file.read}
    Doh.db.query("INSERT INTO #@table SET migrated_at = NOW(), name = #{migrate_name.to_sql}, sql_applied = #{contents.to_sql}")
    [true, "migration #{migrate_name} applied successfully"]
  rescue Exception => excpt
    [false, excpt.message]
  end

  def revert(migrate_name)
    unless migrate_exist?(migrate_name)
      return [false, "migration #{migrate_name} can't be reverted until it has been applied"]
    end
    load_sql(revert_filename(migrate_name))
    Doh.db.query("DELETE FROM #@table WHERE name = #{migrate_name.to_sql}")
    [true, "migration #{migrate_name} reverted successfully"]
  rescue Exception => excpt
    [false, excpt.message]
  end

private
  def apply_filename(migrate_name)
    File.join(@directory, "#{migrate_name}_apply.sql")
  end

  def revert_filename(migrate_name)
    File.join(@directory, "#{migrate_name}_revert.sql")
  end

  def load_sql(filename)
    DohDb.load_sql_using_each_open3(@config, [filename])
  end

  def migrate_exist?(migrate_name)
    Doh.db.select_field("SELECT COUNT(*) FROM #@table WHERE name = #{migrate_name.to_sql}") > 0
  end
end

end
