module DeletedAt
  class Table < Arel::Table

    attr_accessor :shadow

    def initialize(*args, shadow)
      super(*args).tap do
        @shadow = shadow
      end
    end

    def name
      case Thread.current[:selecting_deleted_at]
      when nil, false
        super
      else
        super + shadow.to_s
      end
    end

  end
end
