module DohDb

def self.require_dbtypes
  lib_dbtypes_file = File.join(Doh::root, 'lib/dbtypes.rb')
  require(lib_dbtypes_file) if File.exist?(lib_dbtypes_file)
end

end
