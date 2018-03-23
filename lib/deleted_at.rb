require 'deleted_at/version'
require 'deleted_at/railtie' if defined?(Rails::Railtie)

module DeletedAt

  class << self
    attr_writer :logger
    attr_accessor :registry

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = self.name
        log.level = Logger::INFO
      end
    end
  end

  self.registry = Set.new

end
