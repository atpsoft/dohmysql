module DohDb

def self.set_connector_instance(conn)
  @@connector_instance = conn
end

def self.connector_instance
  @@connector_instance
end

end

module Doh

def self.db
  DohDb.connector_instance.request_handle
end

end
