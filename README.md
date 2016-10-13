# sabina_mnist_example
これは Ruby gem の [sabina](https://github.com/seinosuke/sabina) による手書き数字認識のサンプルです。  
学習に用いるデータはMNISTで、多層パーセプトロンによる識別を行います。

![sabina_demo_01.gif](https://github.com/seinosuke/sabina_mnist_example/blob/master/images/sabina_demo_01.gif)

## 動作環境
* Ubuntu 16.04
* Ruby 2.3.0
* sabina 0.1.0
* gtk2 3.0.8

にて動作を確認しました。  
必要なgemのインストールは以下のコマンドで行います。

    $ bundle install

## GUI起動までの手順
既に学習済みの重みをbin/data/以下にサンプルとして置いてあるので、必要なgem等がインストールできたら

    $ ruby bin/main.rb

で直ちに手書き数字認識用のGUIが起動します。  

一から学習をさせる場合は以下に示す手順の通り、学習用データを用意するところから始めます。

1. [http://yann.lecun.com/exdb/mnist/](http://yann.lecun.com/exdb/mnist/) から .gzファイルをダウンロードして bin/data/ 以下においておく
2. `$ ruby bin/generate_mnist_rb.rb`
3. `$ ruby bin/learn.rb`
4. `$ ruby bin/main.rb`

2回目移行は `$ ruby bin/main.rb` するだけで学習済みの重みを用いた多層パーセプトロンによる手書き数字認識のGUIが起動します。 `$ ruby bin/learn.rb` すると学習をやり直します。

## 使い方
### 数字を書く
マウス左ボタンで線を描き、右ボタンで線を消します。  
CLEARボタンは何も書かれていない状態に戻します。

![sabina_demo_02.gif](https://github.com/seinosuke/sabina_mnist_example/blob/master/images/sabina_demo_02.gif)

### 認識
STARTボタンで認識開始、RESETボタンで数字を書く段階に戻します。
