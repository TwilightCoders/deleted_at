require 'deleted_at/active_record'
require 'deleted_at/table'

module DeletedAt

  def self.scoped(scope=:present)
    Thread.currently(:deleted_at_scope, scope) do
      yield
    end
  end

  def self.scoped?(value=nil)
    (value == nil && scope != value && scope != false) ||
    (value != nil && scope == value)
  end

  def self.scope
    Thread.current[:deleted_at_scope]
  end

  module Core

    cattr_accessor :registry
    self.registry = {}

    def self.prepended(subclass)
      class << subclass
        cattr_accessor :deleted_at
        self.deleted_at = {}
        attr_accessor :deleted_at_type, :vanilla_deleted_at_projections
        @deleted_at_type = :present
      end

      subclass.extend(ClassMethods)
    end

    def self.raise_missing(klass)
      message = "Missing `#{klass.deleted_at[:column]}` in `#{klass.name}` when trying to employ `deleted_at`"
      raise(DeletedAt::MissingColumn, message)
    end

    def self.has_deleted_at_column?(klass)
      klass.columns.map(&:name).include?(klass.deleted_at_column.to_s)
    end

    module ClassMethods

      def deleted_at?
        !self.deleted_at.empty?
      end

      def with_deleted_at(options={}, &block)
        self.deleted_at = DeletedAt::DEFAULT_OPTIONS.merge(options)
        self.deleted_at[:proc] = block if block_given?

        return if ::DeletedAt.disabled? || !connected?

        DeletedAt::Core.raise_missing(self) unless Core.has_deleted_at_column?(self)

        Core.registry[self] = arel_table

        reflect_on_all_associations.each do |association|
          # association.reflection.clear_association_scope_cache
          association.clear_association_scope_cache
        end

        @vanilla_deleted_at_projections = all.projections

        class << self

          # def association(name)
          #   super.tap do |ass|
          #     ass.clear_association_scope_cache
          #   end
          # end

          def all_with_deleted_at
            all_without_deleted_at(scope: :present)
          end

          alias_method_chain :all, :deleted_at

          def arel_table_with_deleted_at
            case DeletedAt.scope
            when :deleted, :all, :present
              send("#{DeletedAt.scope}_table")
            when false
              arel_table_without_deleted_at
            else
              present_table
            end
          end

          alias_method_chain :arel_table, :deleted_at

        end

        self.prepend(DeletedAt::ActiveRecord)

        # TODO: Move to DeletedAt::ActiveRecord
        def self.const_missing(const)
          case const
          when :All
            all_without_deleted_at(scope: :all)
          when :Deleted
            all_without_deleted_at(scope: :deleted)
          end
        end


      # Rescue so that we don't stop migrations from running.
      rescue ::ActiveRecord::StatementInvalid => e
      end

      def deleted_at_attributes
        attributes = {
          deleted_at[:column] => deleted_at[:proc].call
        }
      end

      def deleted_at_column
        deleted_at.dig(:column)
      end

      def init_deleted_at_relations
        instance_variable_get(:@relation_delegate_cache).each do |base, klass|
          puts "#{base} => #{klass}"
          klass.send(:prepend, DeletedAt::Relation)
        end
      end

    end # End ClassMethods

  end

end
