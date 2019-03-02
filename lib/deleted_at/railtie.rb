require 'rails/railtie'
require 'deleted_at/core'
require 'deleted_at/association'
require 'deleted_at/table_definition'

module DeletedAt
  class Railtie < Rails::Railtie
    initializer 'deleted_at.load' do |_app|
      ActiveSupport.on_load(:active_record) do
        ::ActiveRecord::Base.prepend(DeletedAt::Core)
        ::ActiveRecord::ConnectionAdapters::TableDefinition.prepend(DeletedAt::TableDefinition)
        ::ActiveRecord::Associations::Association.prepend(DeletedAt::Association)
      end
    end
  end
end
