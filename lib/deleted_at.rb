require "deleted_at/version"
require 'deleted_at/railtie'
require 'deleted_at/views'

module DeletedAt

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

  private

end
