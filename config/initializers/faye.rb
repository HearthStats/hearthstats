Thread.new do
  system("rackup sync.ru -s thin -E production")
end