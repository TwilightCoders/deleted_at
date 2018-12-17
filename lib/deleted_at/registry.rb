require 'active_support/per_thread_registry'

module DeletedAt
  class QueryRegistry # :nodoc:
    extend ActiveSupport::PerThreadRegistry
  end
end
