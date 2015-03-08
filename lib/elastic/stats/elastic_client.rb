require 'elasticsearch'

module Elastic
  module Stats
    module ElasticClient
      attr_writer :client

      def client
        @client ||= Elasticsearch::Client.new client_options
      end

      def client_options
        @client_options ||= default_options
      end

      def client_options=(options = {})
        client_options.update(options)
      end

      private
      def default_options
        {
          url: ENV['ELASTICSEARCH_URL']
        }
      end
    end
  end
end
