require 'rails/railtie'

module DeletedAt
  class Railtie < Rails::Railtie

    initializer 'deleted_at.load' do
      ActiveSupport.on_load(:active_record) do
        DeletedAt.load
      end
    end

  end
end
