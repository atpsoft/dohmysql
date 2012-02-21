require 'mysql2'
require 'doh/mysql/handle'
require 'doh/mysql/typed_row_builder'

module DohDb

class CacheConnector
  attr_accessor :host, :username, :password, :database, :row_builder, :timeout, :port

  def initialize(host = nil, username = nil, password = nil, database = nil, row_builder = nil)
    @host = host
    @username = username
    @password = password
    @database = database
    @timeout = 1800
    @port = nil
    @row_builder = row_builder || TypedRowBuilder.new
  end

  def request_handle(database = nil)
    if @handle
      close_handle("handle was unused for too long") if passed_timeout?
      @handle = nil if @handle && @handle.closed?
    end
    @last_used = Time.now
    @handle ||= get_new_handle(database)
  end

  def reset
    close_handle("reset")
  end

private
  def close_handle(msg)
    return unless @handle
    dohlog.debug("closing previous database connection - #{msg}")
    @handle.close
    @handle = nil
  end

  def get_new_handle(database = nil)
    database ||= @database
    dbmsg = database.to_s.strip.empty? ? 'no default database' : "database #{database}"
    dohlog.info("connecting to #@host port #@port as username #@username, #{dbmsg}")
    mysqlh = Mysql2::Client.new(:host => @host, :username => @username, :password => @password, :database => database, :port => @port)
    Handle.new(mysqlh, @row_builder)
  end

  def passed_timeout?
    Time.now > @last_used + @timeout
  end
end

end
