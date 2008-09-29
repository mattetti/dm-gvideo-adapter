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
      
      attr_reader :google_user
      
      def initialize(name, uri_or_options)
        super(name, uri_or_options)
        @google_user = Gvideo::User.new(uri_or_options[:user_id])
        raise StandardError, "You must set a user_id" unless @google_user.g_id
      end

      # Reads in a set from a query.
      def read_many(query)
        
        Collection.new(query) do |collection|
          case query.conditions
          when []
            collection.load(@google_user.fetch_videos)
          else
          end
        end

      end

      # def read_one(query)
      #   properties = resource.properties(repository.name).select { |property| !property.lazy? }
      #   properties_with_indexes = Hash[*properties.zip((0...properties.size).to_a).flatten]
      # 
      #   set = Collection.new(repository, query.model, properties_with_indexes)
      # 
      #   begin
      #     p query.inspect
      #     video = @user.fetch_video(query)
      #     set.load video
      #   rescue
      #     nil
      #   end
      # end
      
    end #GvideoAdapter
  end #Adapters
end #DataMapper
