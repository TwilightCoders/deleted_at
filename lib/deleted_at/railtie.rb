require 'rails/railtie'
require 'action_controller'
require 'action_controller/railtie'
require 'deleted_at/active_record/base'
require 'deleted_at/active_record/relation'

module DeletedAt
  class Railtie < ::Rails::Railtie

    initializer 'deleted_at.install' do
      ActiveSupport.on_load(:active_record) do
        ::ActiveRecord::Relation.send :prepend, DeletedAt::ActiveRecord::Relation
        ::ActiveRecord::Base.send :include, DeletedAt::ActiveRecord::Base
      end
    end

  end
end
