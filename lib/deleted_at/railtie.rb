require 'rails/railtie'
require 'deleted_at/active_record/base'
require 'deleted_at/active_record/connection_adapters/abstract/schema_definition'

module DeletedAt
  class Railtie < Rails::Railtie
    initializer 'deleted_at.load' do |_app|
      ActiveSupport.on_load(:active_record) do
        ::ActiveRecord::Base.prepend(DeletedAt::ActiveRecord::Base)
        ::ActiveRecord::ConnectionAdapters::TableDefinition.prepend(DeletedAt::ActiveRecord::ConnectionAdapters::TableDefinition)
      end
    end
  end
end
