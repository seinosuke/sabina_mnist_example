module SabinaMnistExample
  module Color
    class << self
      attr_reader :dict

      def alloc_color
        @colormap = Gdk::Colormap.system
        alloc_color_dict
      end

      private def alloc_color_dict
        @dict = {
          :red => Gdk::Color.new(65535, 0, 0),
          :green => Gdk::Color.new(0, 65535, 0),
          :safe_color => Gdk::Color.new(102*255, 204*255, 204*255),
          :blue => Gdk::Color.new(0, 0, 65535),
          :cyan => Gdk::Color.new(0, 65535, 65535),
          :yellow => Gdk::Color.new(65535, 65535, 0),
          :orange => Gdk::Color.new(255*255, 165*255, 0),
          :black => Gdk::Color.new(0, 0, 0),
          :gray => Gdk::Color.new(50000, 50000, 50000),
          :dark_gray => Gdk::Color.new(10000, 10000, 10000),
          :white => Gdk::Color.new(65535, 65535, 65535),
          :brown => Gdk::Color.new(144*255, 116*255, 73*255),
          :light_brown => Gdk::Color.new(224*255, 204*255, 153*255),
        }
        @dict.each do |_, color|
          @colormap.alloc_color(color, false, true)
        end
      end
    end
  end
end
