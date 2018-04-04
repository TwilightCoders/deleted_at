class Admin < User

  default_scope {
    # select(arel_table[Arel.star], arel_table[:tableoid])#
    select(arel_table[:id], arel_table[:kind]).where(kind: 1)
  }

end
