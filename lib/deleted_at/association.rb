module DeletedAt
  module Association


    # Returns the name of the table of the associated class:
    #
    #   post.comments.aliased_table_name # => "comments"
    #
    def aliased_table_name
      klass.arel_table.name
    end

    def skip_statement_cache?
      # super || reflection.active_record.deleted_at?
      super || reflection.source_reflection.active_record.deleted_at?
    end
  end
end
