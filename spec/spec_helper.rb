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
  include DataMapper::Resource::GvideoModel
  
  
end