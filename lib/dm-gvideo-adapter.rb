begin 
  require 'minigems'
rescue LoadError 
  require 'rubygems'
end
require 'dm-core'
require 'gvideo'

module DataMapper
  module Adapters
    class GvideoAdapter < AbstractAdapter
      def initialize(name, uri_or_options)
        super(name, uri_or_options)
        @resource_naming_convention = NamingConventions::Resource::Underscored
      end

      # Reads in a set from a query.
      def read_many(query)
      end

      def read_one(query)
      end
      
    end #GvideoAdapter
  end #Adapters
end #DataMapper
