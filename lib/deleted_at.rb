require 'deleted_at/version'
require 'deleted_at/railtie' if defined?(Rails::Railtie)

module DeletedAt

  MissingColumn = Class.new(StandardError)

  DEFAULT_OPTIONS = {
    column: :deleted_at,
    proc: -> { Time.now.utc }
  }

  class << self
    attr_writer :logger
    attr_reader :disabled

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = self.name
        log.level = Logger::INFO
      end
    end
  end

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

  def self.gemspec
    @gemspec ||= eval(`gem spec deleted_at --ruby`).freeze
  end

  def self.install(model)
    logger.warn <<-STR
    Great news! You're using the new and improved version of DeletedAt. No more table renaming.
    You'll want to migrate your old models to use the new (non-view based) functionality.
    Follow the instructions at #{gemspec.homepage}.
    STR
  end

  def self.uninstall(model)

  end

end
