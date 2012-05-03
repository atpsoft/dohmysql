require 'doh/mysql/migrate/runner'
require 'doh/mysql/database_creator'
require 'open3'

module DohDb

class MigrateAnalyzer
  CHECK_DATABASE = 'dohmysql_migrate_check'
  FILE_PREFIX = '/tmp/dohmysql_migrate_check_'

  def initialize(database)
    @database = database
    @directory = File.join(DohDb.sql_files_path(@database), 'migrate')
    @sql_original = FILE_PREFIX + "#{@database}_original.sql"
    @sql_final = FILE_PREFIX + "#{@database}_final.sql"
  end

  def check(migrate_name)
    DohDb::DatabaseCreator.new.create_database_copy(CHECK_DATABASE, @database, true, false)
    dump_sql(@sql_original)

    runner = DohDb::MigrateRunner.new(@database)

    success, msg = runner.apply(migrate_name)
    return [success, msg] if !success

    success, msg = runner.revert(migrate_name)
    return [success, msg] if !success

    dump_sql(@sql_final)

    diffstr = diff(@sql_original, @sql_final)
    return [false, diffstr] unless diffstr.empty?

    File.delete(@sql_original)
    File.delete(@sql_final)

    [true, "migration #{migrate_name} checked successfully"]
  end

  def verify(migrate_name)
    DohDb::DatabaseCreator.new.create_database_copy(CHECK_DATABASE, @database, true, false)
    dump_sql(@sql_original)

    runner = DohDb::MigrateRunner.new(@database)

    success, msg = runner.apply(migrate_name)
    return [success, msg] if !success

    dump_sql(@sql_final)

    diffstr = diff(@sql_original, @sql_final)
    return [false, diffstr] unless diffstr.empty?

    File.delete(@sql_original)
    File.delete(@sql_final)

    [true, "migration #{migrate_name} verified successfully"]
  end

private
  def execute_cmd(cmd)
    dohlog.debug("executing: #{cmd}")
    stdin, stdout, stderr = Open3.popen3(cmd)
    stdoutstr = stdout.read
    stdout.close
    stderrstr = stderr.read
    raise "stderr: #{stderrstr}" if !stderrstr.empty?
    stdoutstr
  end

  def dump_sql(fname)
    sql = execute_cmd("mysqldump -uroot -d #{CHECK_DATABASE}")
    sql = remove_unwanted_comparisons(sql)
    sql = sql.split(/[\r|\n]+/)
    output = []
    current_keys = []
    #ignore order of keys
    sql.each do |line|
      if line =~ /(.*KEY[^,]*),?/
        current_keys.push($1)
      else
        output.concat(current_keys.sort)
        output.push(line)
        current_keys = []
      end
    end

    File.open(fname, 'wb') do |file|
      output.each do |line|
        file.write(line + "\n")
      end
    end
  end

  def remove_unwanted_comparisons(sql)
    regexp = /--.-- Temporary table structure for view[^;]*;[^;]*;[^;]*;/m
    regexp2 = /--.-- Table structure for table `[^;]*_deleteme`[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;/m
    sql.gsub(regexp, '').gsub(regexp2, '')
  end

  def remove_safe_diff_lines(result)
    result.dup.delete_if do |elem|
      elem =~ /\d+c\d+/ || elem =~ /-- Dump completed on.*/ || elem == '---' || elem =~ /.*ENGINE.*AUTO_INCREMENT=.*/ || elem =~ /.*ENGINE.*DEFAULT CHARSET=.*/
    end
  end

  def diff(file1, file2)
    result = remove_safe_diff_lines(execute_cmd("diff -b #{file1} #{file2}").split(/[\r|\n]+/))
    if result.empty?
      ''
    else
      "#{file1} and #{file2} differ\n" + result.join("\n")
    end
  end
end

end
