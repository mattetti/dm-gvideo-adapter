

module DataMapper
  module Resource
    module GvideoModel
      
      def self.include(base)
        base.send :property, :docid, String
        base.send :property, :title, String
        base.send :property, :video_url, String
        base.send :property, :duration, Integer
        base.send :property, :duration_in_minutes, String
        base.send :property, :thumbnail_url, String
        base.send :property, :embed_player, String
      end
      
    end # GvideoModel
  end # Resource
end # DataMapper