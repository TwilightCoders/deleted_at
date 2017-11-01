require "deleted_at/version"
require 'deleted_at/views'
require 'deleted_at/active_record/base'
require 'deleted_at/active_record/relation'

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
    ::ActiveRecord::Relation.send :include, DeletedAt::ActiveRecord::Relation
    ::ActiveRecord::Base.send :include, DeletedAt::ActiveRecord::Base
  end

  def self.install(model)
    DeletedAt::Views.install_present_view(model)
    DeletedAt::Views.install_deleted_view(model)

    # Now that the views have been installed, initialize the new class extensions
    # e.g. User -> User::All and User::Deleted
    model.with_deleted_at
  end

  def self.uninstall(model)
    DeletedAt::Views.uninstall_deleted_view(model)
    DeletedAt::Views.uninstall_present_view(model)

    # We've removed the database views, now remove the class extensions
    model.remove_class_views
  end

  def self.get_truthy_value_from_psql(result)
    # Some versions of PSQL return {"?column?"=>"t"}
    # instead of {"first"=>"t"}, so we're saying screw it,
    # just give me the first value of whatever is returned
    result.try(:first).try(:values).try(:first) == 't'
  end

  private

end
