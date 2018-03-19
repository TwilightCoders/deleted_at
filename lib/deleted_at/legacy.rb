module DeletedAt
  module Legacy
    def self.uninstall(model)
      return false unless model.has_deleted_at_column?

      uninstall_deleted_view(model)
      uninstall_present_view(model)
    end

    private

    def self.present_view(model)
      "#{model.table_name}"
    end

    def self.deleted_view(model)
      "#{model.table_name}/deleted"
    end

    def self.all_table(model)
      "#{model.table_name}/all"
    end

    def self.uninstall_present_view(model)
      # Legacy
      model.connection.execute("DROP VIEW IF EXISTS \"#{model.table_name}/present\"")
      # New
      return unless all_table_exists?(model)
      model.connection.execute("DROP VIEW IF EXISTS \"#{present_view(model)}\"")
      model.connection.execute("ALTER TABLE \"#{all_table(model)}\" RENAME TO \"#{present_view(model)}\"")
    end

    def self.uninstall_deleted_view(model)
      model.connection.execute("DROP VIEW IF EXISTS \"#{deleted_view(model)}\"")
    end

    def self.while_spoofing_table_name(model, new_name, &block)
      old_name = model.table_name
      model.table_name = new_name
      yield
      model.table_name = old_name
    end
  end
end
