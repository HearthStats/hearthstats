require 'elasticsearch/model' 
Elasticsearch::Model.client = Elasticsearch::Client.new({url: '52.26.74.47:9200',logger: Rails.logger, logs: true})