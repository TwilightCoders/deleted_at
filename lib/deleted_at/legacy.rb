module DeletedAt
  module Legacy
    def self.uninstall(model)
      return false unless Core.has_deleted_at_column?(model)

      uninstall_deleted_view(model)
      uninstall_present_view(model)
    end

    def self.install(model)
      return false unless Core.has_deleted_at_column?(model)

      model.unframed do
        install_present_view(model)
        install_deleted_view(model)
      end
    end

    private

    def self.install_present_view(model)
      # uninstall_present_view(model)
      present_table_name = present_view(model)

      while_spoofing_table_name(model, all_table(model)) do
        model.connection.execute("ALTER TABLE \"#{present_table_name}\" RENAME TO \"#{model.table_name}\"")
        model.connection.execute <<-SQL
          CREATE OR REPLACE VIEW "#{present_table_name}"
          AS #{ model.select('*').where(model.deleted_at[:column] => nil).to_sql }
        SQL
      end
    end

    def self.install_deleted_view(model)
      return DeletedAt.logger.warn("You must install the all/present tables/views first!") unless all_table_exists?(model)
      table_name = deleted_view(model)

      while_spoofing_table_name(model, all_table(model)) do
        model.connection.execute <<-SQL
          CREATE OR REPLACE VIEW "#{table_name}"
          AS #{ model.select('*').where.not(model.deleted_at[:column] => nil).to_sql }
        SQL
      end
    end

    def self.all_table_exists?(model)
      query = model.connection.execute <<-SQL
        SELECT EXISTS (
          SELECT true
          FROM   information_schema.tables
          WHERE  table_name = '#{all_table(model)}'
        ) AS exists;
      SQL
      query.first['exists']
    end

    def self.deleted_view_exists?(model)
      query = model.connection.execute <<-SQL
        SELECT EXISTS (
          SELECT true
          FROM   information_schema.tables
          WHERE  table_name = '#{deleted_view(model)}'
        ) AS exists;
      SQL
      query.first['exists']
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
