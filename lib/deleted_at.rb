require "deleted_at/version"

require 'action_controller'
require 'action_controller/railtie'
require 'deleted_at/active_record/base'
require 'deleted_at/active_record/relation'

module DeletedAt


  def self.install(model)
    DeletedAt::Views.install_present_view(model)
    DeletedAt::Views.install_deleted_view(model)
  end

  def self.uninstall(model)
    DeletedAt::Views.uninstall_deleted_view(model)
    DeletedAt::Views.uninstall_present_view(model)
  end

  private

end
