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
    lambda{ DataMapper.setup(:default, {:adapter  => 'gvideo'}) }.should raise_error(GvideoInterface::FetchError)
  end

  describe "getting all resources" do
    
    before(:all) do
      @gvideos = @google_user.fetch_videos
      @videos = Video.all
    end
    
    it "should get a set of videos" do
      @videos.should_not be_nil
      @videos.first.should be_an_instance_of(Video)
    end
    
    it "should have all the videos" do
      @videos.length.should == @gvideos.length
    end
    
    it "should be able to retrieve itams using a title (string) condition" do
      videos = @videos.all(:title => "Durex: The Garden")
      videos.length.should == 1
      videos.first.title.should == "Durex: The Garden"
    end
    
    it "should be able to retrieve items using a title (regexp) condition" do
      videos = @videos.all(:title.like => "The Garden")
      videos.length.should == 1
      videos.first.title.should == "Durex: The Garden"
    end
    
    it "should be able to retrieve items using a duration (integer) condition (seconds)" do
      videos = @videos.all(:duration => 12)
      videos.length.should == 2
    end
    
    it "should be able to retrieve items using a duration condition :gte " do
      videos = @videos.all(:duration.gte => 13)
      videos.length.should < @gvideos.length
    end
    
    it "should be able to retrieve items using a duration condition :lte " do
      videos = @videos.all(:duration.lte => 12)
      videos.length.should < @gvideos.length
      (@videos.all(:duration.gte => 13).length + @videos.all(:duration.lte => 12).length).should == @gvideos.length
    end
    
    it "should be able to use 2 duration conditions" do
      videos = @videos.all(:duration.lte => 12, :duration.gte => 12)
      videos.length.should == @videos.all(:duration => 12).length
    end
    
  end
  
  describe "getting one resource" do
    before(:all) do
      @video = Video.first
    end
    
    it "should have all the attributes of a video" do
      methods = %W{docid title video_url duration duration_in_minutes thumbnail_url embed_player}
      methods.each do |meth|
        @video.send(meth.to_sym).should_not be_nil
      end
    end
    
  end
  
  
end