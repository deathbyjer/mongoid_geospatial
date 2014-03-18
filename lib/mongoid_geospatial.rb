require 'mongoid'
require 'active_support/core_ext/string/inflections'
require 'active_support/concern'
require 'mongoid_geospatial/geospatial'
require 'mongoid_geospatial/helpers/spatial'
require 'mongoid_geospatial/helpers/sphere'
require 'mongoid_geospatial/helpers/delegate'

require 'mongoid_geospatial/fields/geometry_field'

%w{point geo_point circle box line polygon}.each do |type|
  require "mongoid_geospatial/fields/#{type}"
end
