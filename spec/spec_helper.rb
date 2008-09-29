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
  
  
end