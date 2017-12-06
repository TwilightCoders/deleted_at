require 'active_record'
require 'deleted_at/views'

module DeletedAt
  module ActiveRecord
    module Base
      extend ActiveSupport::Concern

      included do
        class_attribute :archive_with_deleted_at
        class_attribute :deleted_at_column

          [:archive_with_deleted_at?, :archive_with_deleted_by?].each do |sym|
            define_method(sym) do
              self.class.archive_with_deleted_at
            end
          end

        self.archive_with_deleted_at = false
      end

      module ClassMethods

        def with_deleted_at(options={})

          return DeletedAt.logger.warn("No DB connection found; skipping deleted_at initialization") unless ::ActiveRecord::Base.connected?

          DeletedAt::ActiveRecord::Base.parse_options(self, options)

          unless has_deleted_at_views?
            return DeletedAt.logger.warn("You're trying to use `with_deleted_at` on #{name} but you have not installed the views, yet.")
          end

          unless has_deleted_at_column?
            return DeletedAt.logger.warn("Missing `#{deleted_at_column}` in `#{name}` when trying to employ `deleted_at`")
          end

          self.archive_with_deleted_at = true

          # We are confident at this point that the tables and views have been setup.
          # We need to do a bit of wizardy by setting the table name to the actual table
          # (at this point: model/all), such that the model has all the information
          # regarding its structure and intended behavior. (e.g. setting primary key)
          DeletedAt::Views.while_spoofing_table_name(self, ::DeletedAt::Views.all_table(self)) do
            reset_primary_key
          end

          DeletedAt::ActiveRecord::Base.setup_class_views(self)
        end



        def has_deleted_at_column?
          columns.map(&:name).include?(deleted_at_column)
        end

        def has_deleted_at_views?
          ::DeletedAt::Views.all_table_exists?(self) && ::DeletedAt::Views.deleted_view_exists?(self)
        end

        def deleted_at_attributes
          attributes = {
            deleted_at_column => Time.now.utc
          }


          attributes
        end

      end # End ClassMethods

      def destroy
        if self.archive_with_deleted_at?
          with_transaction_returning_status do
            run_callbacks :destroy do
              update_columns(self.class.deleted_at_attributes)
              self
            end
          end
        else
          super
        end
      end

      def self.remove_class_views(model)
        model.send(:remove_const, :All) if model.const_defined?(:All)
        model.send(:remove_const, :Deleted) if model.const_defined?(:Deleted)
      end

      def self.parse_options(model, options)
        model.deleted_at_column      = (options.try(:[], :deleted_at).try(:[], :column) || :deleted_at).to_s
      end


      def self.setup_class_views(model)
        model.const_set(:All, Class.new(model) do |klass|
          class_eval <<-AAA
            self.table_name = '#{::DeletedAt::Views.all_table(klass)}'
          AAA
        end)

        model.const_set(:Deleted, Class.new(model) do |klass|
          class_eval <<-AAA
            self.table_name = '#{::DeletedAt::Views.deleted_view(klass)}'
          AAA
        end)
      end

    end

  end
end
