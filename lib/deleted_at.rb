require "deleted_at/version"
require 'deleted_at/railtie' if defined? ::Rails::Railtie

module DeletedAt

  def self.install(model)
    DeletedAt::Views.create_deleted_view(model)
    DeletedAt::Views.create_present_view(model)
  end

  def self.uninstall(model)
    DeletedAt::Views.destroy_deleted_view(model)
    DeletedAt::Views.destroy_present_view(model)
  end

end
