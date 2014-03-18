module Mongoid
  module Geospatial
    # Point
    #
    class GeoPoint < Point
      include Enumerable

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
          return nil if str.empty?
          array_to_structure str.split(/,|\s/).reject(&:empty?).map(&:to_f)
        end

        # Also makes life easier:
        # [] -> nil
        def from_array(ary)
          return nil if ary.empty?
          array_to_structure ary[0..1].map(&:to_f)
        end

        # Throw error on wrong hash, just for a change.
        def from_hash(hsh)
          fail "Hash must have at least 2 items" if hsh.size < 2
          array_to_structure [from_hash_x(hsh), from_hash_y(hsh)]
        end

        def from_hash_y(hsh)
          v = (Mongoid::Geospatial.lat_symbols & hsh.keys).first
          return hsh[v].to_f if !v.nil? && hsh[v]
          fail "Hash must contain #{Mongoid::Geospatial.lat_symbols.inspect} if Ruby version is less than 1.9" if RUBY_VERSION.to_f < 1.9
          fail "Hash cannot contain #{Mongoid::Geospatial.lng_symbols.inspect} as the second item if there is no #{Mongoid::Geospatial.lat_symbols.inspect}" if Mongoid::Geospatial.lng_symbols.index(hsh.keys[1])
          hsh.values[1].to_f
        end

        def from_hash_x(hsh)
          v = (Mongoid::Geospatial.lng_symbols & hsh.keys).first
          return hsh[v].to_f if !v.nil? && hsh[v]
          fail "Hash cannot contain #{Mongoid::Geospatial.lat_symbols.inspect} as the first item if there is no #{Mongoid::Geospatial.lng_symbols.inspect}" if Mongoid::Geospatial.lat_symbols.index(keys[0])
          values[0].to_f
        end

        # Database -> Object
        def demongoize(object)
          return nil unless object and object.is_a?(Hash)
          return Point.new(*object[:coordinates]) if object[:coordinates]
          return Point.new(*object["coordinates"]) if object["coordinates"]
        end

        def mongoize(object)
          case object
          when Point  then object.mongoize
          when String then from_string(object)
          when Array  then from_array(object)
          when Hash   then from_hash(object)
          when NilClass then nil
          else
            return object.to_xy if object.respond_to?(:to_xy)
            fail 'Invalid Point'
          end
        end

        # Converts the object that was supplied to a criteria
        # into a database friendly form.
        def evolve(object)
          object.respond_to?(:x) ? object.mongoize : object
        end

      end # << self

    end # Point
  end # Geospatial
end # Mongoid
