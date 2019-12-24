class Admin < User

  with_deleted_at

  default_scope {
    # select(arel_table[Arel.star], arel_table[:tableoid])#
    select(arel_table[:id], arel_table[:kind]).where(kind: 1)
  }

end
