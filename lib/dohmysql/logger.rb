module DohDb

class StubLogger
  def self.call(group, msg); end
end

@logger = StubLogger
def self.logger
  @logger
end

def self.set_logger(logger)
  @logger = logger
end

end
