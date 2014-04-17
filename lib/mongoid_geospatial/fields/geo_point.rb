module Mongoid
  module Geospatial
    # Point
    #
    class GeoPoint < Point
      include Enumerable



      def initialize(x = nil, y = nil)
        if x && y
          @x, @y = x, y
        end
      end

      # Object -> Database
      # Let's store NilClass if we are invalid.
      def to_a
        return nil unless x && y
        [x, y]
      end

      def mongoize
        return nil unless x && y
        { type: "Point", coordinates: self.to_a }
      end

      alias_method :to_xy, :to_a

      def [](args)
        to_a[args]
      end

      class << self
        def array_to_structure(arr)
          return nil if arr.nil?
          {type: "Point", coordinates:arr}
        end
        # Makes life easier:
        # "" -> nil
        def from_string(str)
          array_to_structure super
        end

        # Also makes life easier:
        # [] -> nil
        def from_array(ary)
          array_to_structure super
        end

        # Throw error on wrong hash, just for a change.
        def from_hash(hsh)
          array_to_structure super
        end

        # Database -> Object
        def demongoize(object)
          return nil unless object and object.is_a?(Hash)
          return Point.new(*object[:coordinates]) if object[:coordinates]
          return Point.new(*object["coordinates"]) if object["coordinates"]
        end

      end # << self

    end # Point
  end # Geospatial
end # Mongoid
