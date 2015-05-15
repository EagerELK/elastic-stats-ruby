require 'elasticsearch'

module Elastic
  module Stats
    # Module to set up and manage the Elasticsearch client
    module ElasticClient
      attr_writer :client
      attr_accessor :index, :type

      def client
        @client ||= Elasticsearch::Client.new client_options
      end

      def client_options
        @client_options ||= default_options
      end

      def client_options=(options = {})
        client_options.update(options)
      end

      def search(options = {})
        client.search({ index: index, type: type }.merge(options))
      end

      def analyze(options = {})
        client.indices.analyze({ index: index, type: type }.merge(options))
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
