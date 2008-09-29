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
          repository = query.repository
          properties = query.fields
          properties_with_indexes = Hash[*properties.zip((0...properties.size).to_a).flatten]

          options = extract_options(query.conditions)
          
          begin
            results = @google_user.fetch_videos(options)
          rescue
            raise GvideoInterface::FetchError,  "Couldn't retrieve the videos"
          end

          # This is the core logic that handles the difference between all/first
          results.each do |result|
            props = props_from_result(properties_with_indexes, result, repository)
            arr ? set.load(props) : (break set.load(props, query))
          end
          
        end
      
        # extracts an array of values in the same order passed as the first argument
        # a Collection instance needs to load an array of arrays with the attributes set
        # in the proper order
        def props_from_result(properties_with_indexes, result, repo)
          properties_with_indexes.inject([]) do |accum, (prop, idx)|
            meth = obj_attr(prop, repo, result.class)
            accum[idx] = result.send(meth)
            accum
          end
        end
        
        # figures out the method to call to retrieve an object prop
        def obj_attr(prop, repository, klass)
          meth = klass.instance_methods.
            grep(/^#{prop.field(repository.name)}$/i)
          meth && !meth.empty? ? meth[0] : meth
        end
        
        def extract_options(query_conditions)
          options = {}
          duration_range = {:min => nil, :max => nil}
          duration_matcher = nil
          case query_conditions
          when []
          else
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
          end
        
          return options
        end
      
    end #GvideoAdapter
  end #Adapters
end #DataMapper
