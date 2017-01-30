module DeletedAt
  module Views

    def self.create_present_view(model)
      table_name = present_view(model)
      model.connection.execute <<-SQL
        CREATE OR REPLACE VIEW "#{table_name}"
        AS SELECT * FROM "#{model.original_table_name}" WHERE #{model.deleted_at_column} IS NULL;
      SQL
      # AS SELECT #{cols.join(', ')} FROM "#{model.original_table_name}" WHERE #{model.deleted_at_column} IS NULL;
      return table_name
    end

    def self.create_deleted_view(model)
      table_name = deleted_view(model)
      model.connection.execute <<-SQL
        CREATE OR REPLACE VIEW "#{table_name}"
        AS SELECT * FROM "#{model.original_table_name}" WHERE #{model.deleted_at_column} IS NOT NULL;
      SQL
      return table_name
    end

    def self.present_view_exists?(model)
      query = model.connection.execute <<-SQL
        SELECT EXISTS (
          SELECT 1
          FROM   information_schema.tables
          WHERE  table_name = '#{present_view(model)}'
        );
      SQL
      query.first['exists'] == 't'
    end

    def self.deleted_view_exists?(model)
      query = model.connection.execute <<-SQL
        SELECT EXISTS (
          SELECT 1
          FROM   information_schema.tables
          WHERE  table_name = '#{deleted_view(model)}'
        );
      SQL
      query.first['exists'] == 't'
    end

    def self.present_view(model)
      "#{model.original_table_name}/present"
    end

    def self.deleted_view(model)
      "#{model.original_table_name}/deleted"
    end

    def self.destroy_present_view(model)
      model.connection.execute("DROP VIEW IF EXISTS \"#{present_view(model)}\"")
    end

    def self.destroy_deleted_view(model)
      model.connection.execute("DROP VIEW IF EXISTS \"#{deleted_view(model)}\"")
    end
  end
end
