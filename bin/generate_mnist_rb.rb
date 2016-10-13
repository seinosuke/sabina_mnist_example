require 'zlib'
require 'sabina'
require 'pstore'

def read_images(file_path)
  Zlib::GzipReader.open(file_path) do |f|
    magic, n_images = f.read(8).unpack('N2')
    raise "This is not MNIST image file" if magic != 2051
    n_rows, n_cols = f.read(8).unpack('N2')
    Array.new(n_images) do
      f.read(n_rows * n_cols).unpack('C*')
    end
  end
end

def read_labels(file_path)
  Zlib::GzipReader.open(file_path) do |f|
    magic, n_labels = f.read(8).unpack('N2')
    raise "This is not MNIST label file" if magic != 2049
    f.read(n_labels).unpack('C*')
  end
end

##################################################
# 訓練データのcsvファイル作成
##################################################
train_images = read_images(File.expand_path('../', __FILE__) << "/data/train-images-idx3-ubyte.gz")
train_labels = read_labels(File.expand_path('../', __FILE__) << "/data/train-labels-idx1-ubyte.gz")
DIM = train_images.first.size

training_csvfile_path = File.expand_path('../', __FILE__) << "/data/mnist_training_data.csv"
puts training_csvfile_path
File.open(training_csvfile_path, 'w') do |file|
  file.puts DIM.times.map { |d| "x#{d}" }.join(",") << ",label"
  train_images.zip(train_labels).each do |image, label|
    file.puts image.join(",") << ",#{label}"
  end
end

##################################################
# テストデータのcsvファイル作成
##################################################
test_images = read_images(File.expand_path('../', __FILE__) << "/data/t10k-images-idx3-ubyte.gz")
test_labels = read_labels(File.expand_path('../', __FILE__) << "/data/t10k-labels-idx1-ubyte.gz")

test_csvfile_path = File.expand_path('../', __FILE__) << "/data/mnist_test_data.csv"
puts test_csvfile_path
File.open(test_csvfile_path, 'w') do |file|
  file.puts DIM.times.map { |d| "x#{d}" }.join(",") << ",label"
  test_images.zip(test_labels).each do |image, label|
    file.puts image.join(",") << ",#{label}"
  end
end

##################################################
# PStoreでオブジェクトのdbファイル作成
##################################################
training_data = Sabina::MultilayerPerceptron.load_csv(training_csvfile_path)
training_data.map! { |data| { :d => data[:d], :x => data[:x].map { |v| v / 255.0 } } }

test_data = Sabina::MultilayerPerceptron.load_csv(test_csvfile_path)
test_data.map! { |data| { :d => data[:d], :x => data[:x].map { |v| v / 255.0 } } }

db = PStore.new(File.expand_path('../', __FILE__) << "/data/mnist_rb.db")
db.transaction do
  db[:training_data] = training_data
  db[:test_data] = test_data
end
