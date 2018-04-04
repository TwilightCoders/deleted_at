require 'deleted_at/version'
require 'core_ext/thread'
require 'deleted_at/railtie' if defined?(Rails::Railtie)

module DeletedAt

  MissingColumn = Class.new(StandardError)

  DEFAULT_OPTIONS = {
    column: :deleted_at
  }

  class << self
    attr_writer :logger
    attr_accessor :registry
    attr_reader :disabled

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = self.name
        log.level = Logger::INFO
      end
    end
  end

  self.registry = Set.new
  @disabled = false

  def self.disabled?
    @disabled == true
  end

  def self.disable
    @disabled = true
  end

  def self.enable
    @disabled = false
  end

  def self.install(model)
    warn <<-STR
    Great news! You're using the new and improved version of DeletedAt. No more table renaming.
    You'll want to migrate your old models to use the new (non-view based) functionality.
    STR
  end

  def self.uninstall(model)
  end

end
