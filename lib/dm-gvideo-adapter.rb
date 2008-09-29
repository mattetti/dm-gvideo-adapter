begin 
  require 'minigems'
rescue LoadError 
  require 'rubygems'
end
require 'dm-core'
require 'gvideo'

module GvideoInterface
  class FetchError      < StandardError; end
  class SettingsError   < StandardError; end
  class ConditionsError < StandardError; end
end


module DataMapper
  module Adapters
    class GvideoAdapter < AbstractAdapter
      
      attr_reader :google_user
      
      def initialize(name, uri_or_options)
        super(name, uri_or_options)
        @google_user = Gvideo::User.new(uri_or_options[:user_id])
        raise GvideoInterface::FetchError, "You must set a user_id" unless @google_user.g_id
      end

      # Reads in a set from a query.
      def read_many(query)
        Collection.new(query) do |set|
          read(query, set, true)
        end
      end

      def read_one(query)
        read(query, query.model, false)
      end
      
      private
      
        # query = the DM Query instance
        # set = a Collection instance
        # arr boolean used to specify if the returned value should be an array or a single object instance
        def read(query, set, arr = true)
          options = extract_options(query.conditions)
          
          repository_name = query.repository.name
          properties = query.fields
          
          begin
            results = @google_user.fetch_videos(options)
          rescue
            raise GvideoInterface::FetchError,  "Couldn't retrieve the videos"
          end

          results.each do |result|
            values = result_values(result, properties, repository_name)
            # This is the core logic that handles the difference between all/first
            arr ? set.load(values) : (break set.load(values, query))
          end
          
        end
        
        def result_values(result, properties, repository_name)
          properties.map { |p| result.send(p.field(repository_name)) }
        end
        
        def extract_options(query_conditions)
          options = {}
          duration_range = {:min => nil, :max => nil}
          duration_matcher = nil
            query_conditions.each do |condition|
              op, prop, value = condition
              case prop.field
                when "title"
                  if op == :eql
                    title_matcher = value
                  elsif op == :like
                    title_matcher = Regexp.new(value)
                  end
                  options.merge!({:title => title_matcher})
                
                when "duration"
                  raise GvideoInterface::ConditionsError, "duration in seconds needs to be expressed using an Integer" unless value.is_a?(Integer)
                  case op  
                    when :eql then duration_matcher = value
                    when :gte then duration_range[:min] = value
                    when :lte then duration_range[:max] = value
                    when :lt  then duration_range[:max] = value - 1
                    when :gt  then duration_range[:min] = value + 1
                  end
                  
                else 
                  raise GvideoInterface::ConditionsError, "#{prop.field.to_sym} not supported as a condition"
                end
              end
            
            options.merge!({:duration => duration_matcher}) if duration_matcher
            options.merge!({:duration => (duration_range[:min] || 0)..(duration_range[:max] || 9999) }) if (duration_range[:min] || duration_range[:max])
        
          return options
        end
      
    end #GvideoAdapter
  end #Adapters
end #DataMapper
