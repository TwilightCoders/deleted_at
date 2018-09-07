module DeletedAt
  module Relation

    def self.prepended(subclass)
      subclass.class_eval do
        attr_writer :deleted_at_scope

        private

        def deleted_at_scope
          @deleted_at_scope
        end
      end
    end

    def unscope_deleted_at!(table = arel_table)
      # binding.pry
      unscope!(where: [deleted_at[:column], table[deleted_at[:column]], arel_table[deleted_at[:column]]])
    end

    def with_deleted
      # binding.pry
      unscope_deleted_at!
    end

    def only_deleted(table = arel_table)
      unscope_deleted_at!
      where!(table[deleted_at[:column]].not_eq(nil))
      # unscope_deleted_at.where!(::ActiveRecord::QueryMethods::WhereChain.new(self).not(deleted_at[:column] => nil))
    end

    def only_present(table = arel_table)
      unscope_deleted_at!
      where!(table[deleted_at[:column]].eq(nil))
      # unscope_deleted_at.where!(deleted_at[:column] => nil)
    end

    def build_deleted_at_where(table = arel_table)
        # binding.pry
      case deleted_at_scope
      when :All
        unscope_deleted_at!(table)
      when :Deleted
        only_deleted(table)
      when :Present, nil
        only_present(table)
        # unscope_deleted_at.where(deleted_at[:column] => nil)
      end
    end

    def build_arel
      ta = (from_value && build_from) || arel_table
      build_deleted_at_where(ta)
      super
    end

    def delete_all(*args)
      if args.pop
        ActiveSupport::Deprecation.warn(<<~STR)
          Passing conditions to delete_all is not supported in DeletedAt
          To achieve the same use where(conditions).delete_all.
        STR
      end
      update_all(klass.deleted_at_attributes)
    end
  end
end
