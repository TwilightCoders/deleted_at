require "deleted_at/version"
require 'deleted_at/views'
require 'deleted_at/active_record/base'
require 'deleted_at/active_record/relation'
require 'deleted_at/active_record/connection_adapters/abstract/schema_definition'

require 'deleted_at/railtie' if defined?(Rails::Railtie)

module DeletedAt

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = self.name
        log.level = Logger::INFO
      end
    end
  end

  def self.load
    ::ActiveRecord::Relation.send :prepend, DeletedAt::ActiveRecord::Relation
    ::ActiveRecord::Base.send :include, DeletedAt::ActiveRecord::Base
    ::ActiveRecord::ConnectionAdapters::TableDefinition.send :prepend, DeletedAt::ActiveRecord::ConnectionAdapters::TableDefinition
  end

  def self.install(model)
    return false unless model.has_deleted_at_column?

    DeletedAt::Views.install_present_view(model)
    DeletedAt::Views.install_deleted_view(model)

    # Now that the views have been installed, initialize the new class extensions
    # e.g. User -> User::All and User::Deleted
    model.with_deleted_at
  end

  def self.uninstall(model)
    return false unless model.has_deleted_at_column?

    DeletedAt::Views.uninstall_deleted_view(model)
    DeletedAt::Views.uninstall_present_view(model)

    # We've removed the database views, now remove the class extensions
    DeletedAt::ActiveRecord::Base.remove_class_views(model)
  end

  def self.testify(value)
    value == true || value == 't' || value == 1 || value == '1'
  end

  private

end
