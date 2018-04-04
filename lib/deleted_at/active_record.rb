require 'active_record'
require 'deleted_at/relation'

module DeletedAt
  module ActiveRecord

    def self.prepended(subclass)
      subclass.const_get(:ActiveRecord_Relation).prepend(DeletedAt::Relation)
      subclass.const_get(:ActiveRecord_AssociationRelation).prepend(DeletedAt::Relation)
      subclass.extend(ClassMethods)
    end

    module ClassMethods

      def inherited(subclass)
        super
        subclass.with_deleted_at self.deleted_at
      end

      def all
        const_get(:Present)
      end

      def const_missing(const)
        case const
        when :All, :Deleted, :Present
          all_without_deleted_at.tap do |rel|
            rel.deleted_at_scope = const
          end
        else super
        end
      end
    end

  end

end
