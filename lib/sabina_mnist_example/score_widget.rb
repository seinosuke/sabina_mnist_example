module SabinaMnistExample
  class ScoreWidget < Gtk::Table
    def initialize(rows, columns, homogeneous)
      @n = rows
      super(rows, columns, homogeneous)
      self.row_spacings = 5
      self.column_spacings = 5
      self.border_width = 5
      init_pbars
      reset
    end

    # 各プログレスバーを初期化する
    private def init_pbars
      fll_shr = Gtk::SHRINK | Gtk::FILL
      fll_exp = Gtk::EXPAND | Gtk::FILL

      @pbars = Array.new(@n) { Gtk::ProgressBar.new }
      @pbars.each_with_index do |pbar, i|
        self.attach(Gtk::Label.new("#{i}"), 0, 1, 0+i, 1+i, fll_shr, fll_shr,  0, 0)
        self.attach(pbar,                   1, 2, 0+i, 1+i, fll_exp, fll_shr,  0, 0)
      end
    end

    # i番目のプログレスバーの色を橙色に
    def highlight(i = 0)
      @pbars[i].modify_bg(Gtk::STATE_SELECTED, Color.dict[:orange])
    end

    # プログレスバーの色を戻してスコアを0に
    def reset
      @pbars.each do |pbar|
        pbar.modify_bg(Gtk::STATE_SELECTED, Color.dict[:safe_color])
      end
      set_scores(Array.new(@n) { 0.0 })
    end

    # スコアをセット
    def set_scores(scores)
      @pbars.each_with_index do |pbar, i|
        pbar.fraction = scores[i]
        pbar.text = scores[i].round(2).to_s
      end
    end
  end
end
