require 'rails/railtie'
require 'deleted_at/active_record/base'
require 'deleted_at/active_record/relation'

module DeletedAt
  class Railtie < Rails::Railtie

    initializer 'deleted_at.load' do
      ActiveSupport.on_load(:active_record) do
        DeletedAt.load
      end
    end

  end
end
