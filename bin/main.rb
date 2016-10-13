$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sabina_mnist_example'

db_file_path = File.expand_path('../', __FILE__) << "/data/mp_rb.db"
window = SabinaMnistExample::Window.new(db_file_path)
window.show_all
Gtk.main
