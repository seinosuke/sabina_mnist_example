module SabinaMnistExample
  class Window < Gtk::Window
    attr_reader :width, :height, :border_width

    def initialize(file_path, title = "sabina")
      super(title)
      @file_path = file_path
      @width = 28*15*1.6
      @height = 28*15
      @border_width = 20
      self.set_size_request(@width + 2*@border_width, @height + 2*@border_width)
      self.resizable = true
      self.border_width = @border_width
      self.double_buffered = true
      self.realize
      self.signal_connect('destroy') { Gtk.main_quit }
      SabinaMnistExample::Color.alloc_color
      @n = 10

      @score_widget = ScoreWidget.new(@n, 2, false)
      @drawing_area = DrawingArea.new(@height, @height)
      @discriminator = Discriminator.new(@file_path)
      pack_widgets

      @drawing_area.realize
      @drawing_area.drawable = @drawing_area.window
      @drawing_area.gc = Gdk::GC.new(@drawing_area.drawable)

      reset
    end

    def reset
      @button_start.sensitive = true
      @button_clear.sensitive = true
      @button_reset.sensitive = false
      @drawing_area.reset
      @score_widget.reset
    end

    # プログレスバーのアニメーションを実行する
    def exec_animation(scores)
      tmp = Array.new(@n) { 0.0 }
      Gtk.timeout_add(10) do
        scores.map.with_index do |score, i|
          tmp[i] < score ? tmp[i] += (0.001 + (score - tmp[i])*0.1) : score
        end
        @score_widget.set_scores(tmp)
        unless scores.find.with_index { |score, i| tmp[i] < score }
          @score_widget.highlight(scores.index scores.max)
          true
        end.!
      end
    end

    private

    # 描画エリアや各種ボタンなどをパッキング
    def pack_widgets
      hbox = Gtk::HBox.new(false, @border_width)
      vbox = Gtk::VBox.new(false, @border_width)

      hbox.pack_start(@drawing_area, true, false, 0)
      vbox.pack_start(button_box, true, false, 0)
      vbox.pack_start(@score_widget, true, true, 0)
      hbox.pack_start(vbox, true, true, 0)
      self.add(hbox)
    end

    # 各種ボタンがパッキングされたウィジェットを返す
    def button_box
      add_buttons
      vbox = Gtk::VBox.new(false, 0)
      [@button_start, @button_clear, @button_reset].each do |button|
        vbox.pack_start(button, true, false, 3)
      end
      vbox
    end

    def add_buttons
      @button_start = Gtk::Button.new("    START    ")
      @button_clear = Gtk::Button.new("    CLEAR    ")
      @button_reset = Gtk::Button.new("    RESET    ")

      # START
      @button_start.signal_connect('clicked') do
        @button_start.sensitive = false
        @button_clear.sensitive = false
        @button_reset.sensitive = true
        @drawing_area.drawable_flag = false
        scores = @discriminator.exec( @drawing_area.nodes.transpose.flatten )
        exec_animation( scores )
      end

      # CLEAR
      @button_clear.signal_connect('clicked') do
        @drawing_area.reset
      end

      # RESET
      @button_reset.signal_connect('clicked') do
        @button_reset.sensitive = false
        @button_reset.sensitive = true
        @button_start.sensitive = true
        reset
      end
    end
  end
end
