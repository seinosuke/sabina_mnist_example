module SabinaMnistExample
  class Discriminator
    def initialize(file_path)
      db = PStore.new(file_path)
      db.transaction(true) do
        options = {
          :layers => [
            Sabina::Layer::MPInputLayer.new(28**2),
            Sabina::Layer::MPHiddenLayer.new(db[:hidden_layer_size]),
            Sabina::Layer::MPOutputLayer.new(10)
          ]
        }
        @mp = Sabina::MultilayerPerceptron.new(options)

        @mp.layers.size.times.map do |l|
          @mp.layers[l].W = db[:weights][l][:W]
          @mp.layers[l].b = db[:weights][l][:b]
        end
      end
    end

    # 手書き数字判別計算結果を返す
    def exec(nodes)
      mat_x = Matrix.columns( [nodes] )
      mat_y = @mp.propagate_forward(mat_x)
      mat_y.t.to_a.flatten
    end
  end
end
