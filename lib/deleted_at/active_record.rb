require 'active_record'
require 'deleted_at/relation'

module DeletedAt
  module ActiveRecord

    def self.prepended(subclass)
      subclass.init_deleted_at_relations
      subclass.extend(ClassMethods)
    end

    def initialize(*args)
      super
      @destroyed = !deleted_at.nil?
    end

    def destroy
      soft_delete
      super
    end

    def delete
      soft_delete
      super
    end

    private

    def soft_delete
      update_columns(self.class.deleted_at_attributes)
      @destroyed = true
    end

    module ClassMethods

      def inherited(subclass)
        super
        subclass.init_deleted_at_relations
      end

      def const_missing(const)
        case const
        when :All, :Deleted
          all.tap do |_query|
            _query.deleted_at_scope = const
          end
        else super
        end
      end

    end

  end

end
