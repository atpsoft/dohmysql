require 'doh/mysql/handle'

module DohDb

class CacheConnector
  attr_accessor :config

  def initialize(config)
    @config = config
    @config[:timeout] ||= 1800
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
    local_config = @config.dup
    local_config[:database] = database if database
    dohlog.info("connecting with config: #{local_config}")
    local_config.delete(:timeout)
    Handle.new(local_config)
  end

  def passed_timeout?
    Time.now > @last_used + @config[:timeout]
  end
end

end
