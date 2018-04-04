require 'active_record'
require 'deleted_at/relation'

module DeletedAt
  module ActiveRecord

    def self.prepended(subclass)
      class << subclass
        cattr_accessor :scoped_deleted do
          nil
        end
        cattr_accessor :scoped_present do
          nil
        end

        alias unscoped_all all unless method_defined?(:unscoped_all)
      end

      subclass.const_get(:ActiveRecord_Relation).prepend(DeletedAt::Relation)
      subclass.const_get(:ActiveRecord_AssociationRelation).prepend(DeletedAt::Relation)
      subclass.extend(ClassMethods)
    end

    module ClassMethods

      def inherited(subclass)
        super
        # TODO: Forward options
        subclass.with_deleted_at
      end

      def all
        const_get(:Present)
      end

      def const_missing(const)
        case const
        when :All, :Deleted, :Present
          unscoped_all.tap do |rel|
            rel.subselect_scope = const
            # ScopeRegistry.set(const) do
            #   arel.subselect = scoped_alias(arel)
            # end
          end
        else super
        end
      end
    end

  end

end
