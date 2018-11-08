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
      cols = deleted_at_columns
      self.select_values -= cols
      unscope!(where: cols)
    end

    def deleted_at_columns(table = arel_table)
      [deleted_at[:column], table[deleted_at[:column]], arel_table[deleted_at[:column]]].uniq
    end

    def with_deleted
      unscope_deleted_at!
    end

    def only_deleted!(table = arel_table)
      unscope_deleted_at!(table)
      where!(table[deleted_at[:column]].not_eq(nil))
      # unscope_deleted_at.where!(::ActiveRecord::QueryMethods::WhereChain.new(self).not(deleted_at[:column] => nil))
    end

    def only_present!(table = arel_table)
      unscope_deleted_at!(table)
      where!(table[deleted_at[:column]].eq(nil))
      # unscope_deleted_at.where!(deleted_at[:column] => nil)
    rescue TypeError => e
      puts "Foo"
    end

    def build_deleted_at_where!(table = arel_table)
        # binding.pry
      case deleted_at_scope
      when :All
        unscope_deleted_at!(table)
      when :Deleted
        only_deleted!(table)
      when :Present, nil
        only_present!(table)
        # unscope_deleted_at.where(deleted_at[:column] => nil)
      end
    end

    def as(other)
      ensure_deleted_at_column_selected!
      super
    end

    def from(value, subquery_name = nil)
      value.ensure_deleted_at_column_selected! if value.class < ::ActiveRecord::Relation
      super
    end

    def calculate(*args)
      @calculating = true
      super
    end

    def ensure_deleted_at_column_selected!(table = arel_table)
      self.select_values -= deleted_at_columns
      _select!(table[deleted_at[:column]]) if select_values.any? && !@calculating
    end

    def ensure_deleted_at_column_grouped!(table = arel_table)
      self.group_values -= deleted_at_columns
      group!(table[deleted_at[:column]]) if group_values.any? && !@calculating
    end

    def build_arel
      ta = (from_value && build_from) || arel_table
      build_deleted_at_where!(ta)
      ensure_deleted_at_column_selected!(ta)
      ensure_deleted_at_column_grouped!(ta)
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
