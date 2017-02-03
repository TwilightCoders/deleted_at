module DeletedAt
  module Views

    def self.install_present_view(model)
      uninstall_present_view(model)
      all_table_name = all_table(model)
      present_table_name = present_view(model)

      model.connection.execute("ALTER TABLE \"#{present_table_name}\" RENAME TO \"#{all_table_name}\"")
      model.connection.execute <<-eos
        CREATE OR REPLACE VIEW "#{present_table_name}"
        AS SELECT * FROM "#{all_table_name}" WHERE #{model.deleted_at_column} IS NULL;
      eos
    end

    def self.install_deleted_view(model)
      return warn("You must install the all/present tables/views first!") unless all_table_exists?(model)
      table_name = deleted_view(model)
      model.connection.execute <<-eos
        CREATE OR REPLACE VIEW "#{table_name}"
        AS SELECT * FROM "#{all_table(model)}" WHERE #{model.deleted_at_column} IS NOT NULL;
      eos
    end

    def self.all_table_exists?(model)
      query = model.connection.execute <<-eos
        SELECT EXISTS (
          SELECT 1
          FROM   information_schema.tables
          WHERE    table_name = '#{all_table(model)}'
        );
      eos
      query.first['exists'] == 't'
    end

    def self.deleted_view_exists?(model)
      query = model.connection.execute <<-eos
        SELECT EXISTS (
          SELECT 1
          FROM   information_schema.tables
          WHERE    table_name = '#{deleted_view(model)}'
        );
      eos
      query.first['exists'] == 't'
    end

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
  end
end
