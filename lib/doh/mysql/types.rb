module DohDb

@@row_types = {}
def self.register_row_type(table, klass)
  @@row_types[table] = klass
end

def self.find_row_type(table)
  @@row_types[table]
end

end
