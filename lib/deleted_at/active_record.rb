module DeletedAt
  module ActiveRecord

    def self.prepended(subclass)
      subclass.extend(ClassMethods)

      subclass.class_eval do
        init_deleted_at_relations
        default_frame { where(deleted_at[:column] => nil) }
        frame :all, -> {}
        frame :deleted, -> { where.not(deleted_at[:column] => nil) }
      end
    end

    def initialize(*args)
      super.tap do
        @destroyed = deleted_at_nil?
      end
    end

    def destroy
      run_callbacks(:destroy) do
        soft_delete
      end
    end

    def delete
      soft_delete
    end

    def destroy!
      run_callbacks(:destroy) do
        soft_delete
      end
    end

    def delete!
      soft_delete
    end

    private

    def soft_delete
      return if destroyed?
      update_columns(self.class.deleted_at_attributes)
      @destroyed = true
      freeze
      self
    end

    def deleted_at_nil?
      !read_attribute(self.class.deleted_at[:column]).nil?
    end

    module ClassMethods

      def inherited(subclass)
        super
        # subclass.init_deleted_at_relations if deleted_at[:inherit]
      end

      def deleted_at_attributes
        attributes = {
          deleted_at[:column] => deleted_at[:proc].call
        }
      end

      def init_deleted_at_relations
        instance_variable_get(:@relation_delegate_cache).each do |base, klass|
          klass.send(:prepend, DeletedAt::Relation)
        end
      end

    end

  end

end
