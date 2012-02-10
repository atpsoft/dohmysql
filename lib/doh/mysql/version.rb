require 'doh/mysql/connector_instance'
require 'yaml'

module DohDb

def self.locked_filename(database)
  File.join(Doh::root, 'database', database, 'migrate/locked.yml')
end

def self.migration_filename(database, version, upordown = 'up')
  version_str = version.to_s.rjust(3, '0')
  File.join(Doh::root, 'database', database, "migrate/#{version_str}_#{upordown}.sql")
end

def self.current_database_version(database = nil)
  if database.nil?
    table = 'version'
  else
    table = database + '.version'
  end
  DohDb::select_field("SELECT version FROM #{table}").to_i
end

def self.latest_database_version(database = nil)
  locked_version = locked_database_version(database)
  unlocked_version = locked_version + 1
  unlocked_migration_file = migration_filename(database, unlocked_version)
  if File.exist?(unlocked_migration_file)
    unlocked_version
  else
    locked_version
  end
end

def self.locked_version_info(database = nil)
  database ||= (DohDb::connector_instance && DohDb::connector_instance.database) || Doh::config['primary_database']
  filename = locked_filename(database)
  return [0, nil] unless File.exist?(filename)
  YAML.load_file(filename)
end

def self.locked_database_version(database = nil)
  locked_version_info(database).first
end

def self.locked_svn_revision(database = nil)
  locked_version_info(database).last
end

def self.update_locked_file(database)
  locked_file = locked_filename(database)
  if File.exist?(locked_file)
    new_version = YAML.load_file(locked_file).first + 1
  else
    new_version = 0
    need_to_add = true
  end

  file_to_check = ''
  if need_to_add
    file_to_check = File.join(Doh::root, "database")
  else
    unlocked_migration_file = migration_filename(database, new_version)
    return [true, "nothing to lock"] unless File.exist?(unlocked_migration_file)

    svnout = `svn st #{unlocked_migration_file}`
    unless svnout.strip.empty?
      return [false, "svn status shows local changes to #{unlocked_migration_file} -- this needs to be resolved before updating the migration locked file"]
    end

    file_to_check = unlocked_migration_file
  end

  `svn update #{file_to_check}`
  svnout = `svn st -v #{file_to_check}`.split("\n")
  svnout =~ /(\d+)/
  revision = svnout.collect {|elem| elem =~ /(\d+)/; $1.to_i}.max
  if !revision
    return [false, "unable to extract svn revision from: '#{svnout}'"]
  end

  outfile = File.new(locked_file, 'w')
  outfile.puts([new_version, revision.to_i].inspect)
  outfile.close

  if need_to_add
    svnout = `svn add #{locked_file}`
    if svnout[0,1] != 'A'
      return [false, "failed to svn add #{locked_file}"]
    end
  end

  msg = "migrate lock for #{database} database, version #{new_version}"
  svnout = `svn ci -m \"#{msg}\"  #{locked_file}`
  unless svnout.index("Committed revision")
    return [false, "failed to svn ci #{locked_file}"]
  end

  [true, "#{locked_file} successfully updated"]
end

end
