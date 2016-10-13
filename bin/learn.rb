$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sabina_mnist_example'
require 'rmagick'

##################################################
# データを読み込み多層パーセプトロンを作成
##################################################
original_data, training_data, test_data = *[]
db = PStore.new(File.expand_path('../', __FILE__) << "/data/mnist_rb.db")
db.transaction(true) do
  training_data = db[:training_data]
  test_data = db[:test_data]
end
training_data = training_data.sample(5000)

DIM = 28**2
K = 10
EPOCH = 200

options = {
  :layers => [
    Sabina::Layer::MPInputLayer.new(DIM),
    Sabina::Layer::MPHiddenLayer.new(50),
    Sabina::Layer::MPOutputLayer.new(K)
  ],
  :mini_batch_size => 10,
  :learning_rate => 0.01,
  :training_data => training_data,
}
mp = Sabina::MultilayerPerceptron.new(options)


##################################################
# 学習開始
##################################################
sampled_training_data = training_data.sample(500)
sampled_test_data = test_data.sample(500)
training_errors, test_errors = [], []

begin
  mp.learn
  training_errors << training_error = mp.error(sampled_training_data)
  test_errors << test_error = mp.error(sampled_test_data)
  puts " training error: #{training_error}"
  puts " test error:     #{test_error}"

  mat_x = Matrix.columns( sampled_test_data.map { |data| data[:x] } )
  mat_y = mp.propagate_forward(mat_x)
  rate = sampled_test_data.zip(mat_y.t.to_a).inject(0.0) do |sum, (input, y)|
    sum + ( input[:d].find_index { |v| v == 1 } == y.index( y.max ) ? 1 : 0 )
  end / 500
  puts " correct rate:   #{rate}"
  puts " [#{("*"*((($c = $c.to_i + 1).to_f / EPOCH)*10).to_i).ljust(9, " ")}]"
  print "\e[4A"; STDOUT.flush;

rescue Interrupt
  break
end while $c < EPOCH


##################################################
# 学習結果の図を作成
##################################################
Open3.popen3('gnuplot') do |gp_in, gp_out, gp_err|
  output_file = File.expand_path('../', __FILE__) << "/result.png"
  gp_in.puts "set terminal png size 800, 400"
  gp_in.puts "set output '#{output_file}'"
  gp_in.puts "set xlabel 'epoch'"
  gp_in.puts "set xtics 10"
  gp_in.puts "set ylabel 'error'"
  gp_in.puts "set ytics 200"
  gp_in.puts "set grid"
  gp_in.puts "set key right top"
  xrange = [0, training_errors.size]
  yrange = [0, (training_errors + test_errors).max + 10]
  gp_in.puts xrange.tap { |f, t| break "set xrange [#{f}:#{t}]" }
  gp_in.puts yrange.tap { |f, t| break "set yrange [#{f}:#{t}]" }
  plot = "plot "

  plot << "'-' with lines lt 1 lw 2 lc rgb 'orange' title 'training error',\\\n"
  plot << "'-' with lines lt 1 lw 2 lc rgb 'blue' title 'test error',\\\n"
  plot.gsub!(/,\\\n\z/, "\n")

  [training_errors, test_errors].each do |errors|
    errors.each_with_index do |error, epoch|
      plot << "#{epoch}, #{error}\n"
    end
    plot << "e\n"
  end

  gp_in.puts plot
  puts output_file
  gp_in.puts "set output"
  gp_in.puts "exit"
  gp_in.close
end


##################################################
# 各層の重み等の情報を保存
##################################################
db = PStore.new(File.expand_path('../', __FILE__) << "/data/mp_rb.db")
db.transaction do
  db[:weights] = mp.layers.size.times.map do |l|
    { :W => mp.layers[l].W, :b => mp.layers[l].b }
  end
  db[:hidden_layer_size] = mp.layers[1].size
end
