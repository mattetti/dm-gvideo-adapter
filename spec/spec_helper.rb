$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')
require 'dm-gvideo-adapter'
require 'gvideo_model'

DataMapper.setup(:default, {
  :adapter  => 'gvideo',
  :user_id  => 'A005148908335059515423'
})

class Video
  include DataMapper::Resource
  
  property :docid, String
  property :title, String
  property :video_url, String
  property :duration, Integer
  property :duration_in_minutes, String
  property :thumbnail_url, String
  property :embed_player, String
  
  ##
  # Simulates Array#first by returning the first entry (when
  # there are no arguments), or transforms the collection's query
  # by applying :limit => n when you supply an Integer. If you
  # provide a conditions hash, or a Query object, the internal
  # query is scoped and a new collection is returned
  #
  # @param [Integer, Hash[Symbol, Object], Query] args
  #
  # @return [DataMapper::Resource, DataMapper::Collection] The
  # first resource in the entries of this collection, or
  # a new collection whose query has been merged
  #
  # @api public
  def first(*args)
    
    # # TODO: this shouldn't be a kicker if scoped_query() is called
    # if loaded?
    #   if args.empty?
    #     return super
    #   elsif args.size == 1 && args.first.kind_of?(Integer)
    #     limit = args.shift
    #     return self.class.new(scoped_query(:limit => limit)) { |c| c.replace(super(limit)) }
    #   end
    # end
    # 
    # query = args.last.respond_to?(:merge) ? args.pop : {}
    # query = scoped_query(query.merge(:limit => args.first || 1))
    # 
    # if args.any?
    #   query.repository.read_many(query)
    # else
    #   query.repository.read_one(query)
    # end
  end
  
end