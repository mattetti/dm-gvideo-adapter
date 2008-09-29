require File.dirname(__FILE__) + '/spec_helper'
require 'gvideo'

describe "dm-gvideo-adapter" do
  
  before(:all) do
    DataMapper.setup(:default, {
      :adapter  => 'gvideo',
      :user_id  => 'A005148908335059515423'
    })
    @adapter = DataMapper::Repository.adapters[:default]
    @google_user = @adapter.google_user
  end
  
  it "should raise an error if the user_id isn't passed" do
    lambda{ DataMapper.setup(:default, {:adapter  => 'gvideo'}) }.should raise_error
  end

  describe "getting all resources" do
    
    before(:all) do
      @gvideos = @google_user.fetch_videos
    end
    
    it "should get a set of videos" do
      videos = Video.all
      videos.should_not be_nil
      videos.first.should be_an_instance_of(Video)
      videos.length.should == @gvideos.length
    end
    
  end
  
  
end