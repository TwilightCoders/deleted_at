require 'deleted_at/active_record'
require 'deleted_at/table'

module DeletedAt

  def self.table_spoofing(value=true)
    Thread.currently(:table_spoofing, value) do
      yield
    end
  end

  def self.table_spoofing?(value=true)
    Thread.current[:table_spoofing] == value
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

      def with_deleted_at(options={}, &block)
        self.deleted_at = DeletedAt::DEFAULT_OPTIONS.merge(options)
        self.deleted_at[:proc] = block if block_given?

        return if ::DeletedAt.disabled? || !connected?

        DeletedAt::Core.raise_missing(self) unless Core.has_deleted_at_column?(self)

        Core.registry[self] = arel_table

        @vanilla_deleted_at_projections = all.projections

        class << self

          def all_with_deleted_at(table = present_table, scope = only_present_records)
            puts "CALLED: #{table.shadow} AND #{scope.to_sql}"
            all_without_deleted_at.tap do |re|
              re.set_deleted_at(table, scope) unless DeletedAt.table_spoofing?(false)
            end
          end

          alias_method_chain :all, :deleted_at
        end

        self.prepend(DeletedAt::ActiveRecord)

        def self.present_table
          @present_table ||= DeletedAt::Table.new(table_name, self, "/present").freeze
        end

        def self.all_table
          @all_table ||= DeletedAt::Table.new(table_name, self, "/all").freeze
        end

        def self.deleted_table
          @deleted_table ||= DeletedAt::Table.new(table_name, self, "/deleted").freeze
        end

        # TODO: Move to DeletedAt::ActiveRecord
        def self.const_missing(const)
          case const
          when :All
            all_with_deleted_at(all_table, all_records)
          when :Deleted
            all_with_deleted_at(deleted_table, only_deleted_records)
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
          klass.send(:prepend, DeletedAt::Relation)
        end
      end

    end # End ClassMethods

  end

end
