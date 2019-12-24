require 'rails/railtie'

module DeletedAt
  class Railtie < Rails::Railtie
    initializer 'deleted_at.load' do |_app|
      ActiveSupport.on_load(:active_record) do
        ::ActiveRecord::Base.prepend(DeletedAt::Core)
        ::ActiveRecord::ConnectionAdapters::TableDefinition.prepend(DeletedAt::TableDefinition)
      end
    end
  end
end
