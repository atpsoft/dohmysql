module DohDb

def self.sql_files_path(database = nil)
  if database
    File.join(Doh.root, "data/mysql/#{database}")
  else
    File.join(Doh.root, 'data/mysql')
  end
end

end
