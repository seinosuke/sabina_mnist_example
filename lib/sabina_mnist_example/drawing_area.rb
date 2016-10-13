module SabinaMnistExample
  class DrawingArea < Gtk::DrawingArea
    attr_accessor :drawable, :gc, :map_size, :drawable_flag
    attr_reader :nodes
    BUTTON_LEFT = 1
    BUTTON_RIGHT = 3
    BLACK = 0.0
    WHITE = 1.0

    def initialize(width, height, size = 28)
      super()
      @width = width
      @height = height
      @map_size = size
      @node_size = @width / @map_size

      self.set_size_request(@width+1, @height+1)
      self.set_app_paintable(true)
      self.set_events(
        Gdk::Event::BUTTON_MOTION_MASK |
        Gdk::Event::BUTTON_PRESS_MASK
      )
      self.signal_connect("expose_event") { clear; draw_grid }
      self.signal_connect('motion_notify_event') { |_, evt| on_motion_notified(evt) }
      self.signal_connect('button_press_event') { |_, evt| on_button_pressed(evt) }
    end

    def reset
      @eraser_flag = false
      @drawable_flag = true
      clear
    end

    def clear
      @gc.set_foreground(Color.dict[:black])
      @drawable.draw_rectangle(@gc, true, 0, 0, @width, @height)
      @nodes = Array.new(@map_size) do
        Array.new(@map_size) { BLACK }
      end
      draw_grid
    end

    private

    def draw_node(x, y, color)
      @nodes[x][y] = case color
        when :black then BLACK
        when :white then WHITE
      end
      x *= @node_size
      y *= @node_size
      @gc.set_foreground(Color.dict[color])
      @drawable.draw_rectangle(@gc, true, x, y, @node_size, @node_size)
      draw_grid
    end

    def draw_grid
      @gc.set_foreground(Color.dict[:white])
      @gc.set_line_attributes(1, Gdk::GC::LINE_SOLID, Gdk::GC::CAP_ROUND, Gdk::GC::JOIN_BEVEL)

      (0..@map_size).each_with_object(@node_size).map(&:*).each do |x|
        @drawable.draw_line(@gc, x, 0, x, @height)
      end
      (0..@map_size).each_with_object(@node_size).map(&:*).each do |y|
        @drawable.draw_line(@gc, 0, y, @width, y)
      end
    end

    def on_motion_notified(event)
      return unless @drawable_flag
      x = event.x.to_i / @node_size
      y = event.y.to_i / @node_size

      [-1, 0, 1].repeated_permutation(2) do |dx, dy|
        xx = x + dx
        yy = y + dy
        if xx.between?(0, @map_size-1) && yy.between?(0, @map_size-1)
          color = @eraser_flag ? :black : :white
          draw_node(xx, yy, color)
        end
      end
    end

    def on_button_pressed(event)
      return unless @drawable_flag
      case event.button
      when BUTTON_LEFT then @eraser_flag = false
      when BUTTON_RIGHT then @eraser_flag = true
      end

      x = event.x.to_i / @node_size
      y = event.y.to_i / @node_size
      [-1, 0, 1].repeated_permutation(2) do |dx, dy|
        xx = x + dx
        yy = y + dy
        if xx.between?(0, @map_size-1) && yy.between?(0, @map_size-1)
          color = @eraser_flag ? :black : :white
          draw_node(xx, yy, color)
        end
      end
    end
  end
end
