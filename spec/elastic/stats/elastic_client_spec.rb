require 'spec_helper'
require 'elastic/stats/elastic_client'

# Testing class for the Elastic::Stats::ElasticClient module
class ElasticClientTest
  include Elastic::Stats::ElasticClient
end

describe Elastic::Stats::ElasticClient do
  subject { ElasticClientTest.new }

  context '#client' do
    it 'allows the client to be set' do
      client = Object.new
      subject.client = client

      expect(subject.client).to be client
    end
  end

  context '#client_options' do
    it 'has sane default options' do
      expect(subject.client_options).to eq(
        url: ENV['ELASTICSEARCH_URL']
      )
    end

    it 'allows the client options to be retrieved' do
      expect(subject.client_options).to eq(url: ENV['ELASTICSEARCH_URL'])
    end
  end

  context '#client_options=' do
    it 'allows the default client options to be added' do
      logger = Object.new
      options  = {
        debug: true,
        logger: logger
      }
      subject.client_options = options

      options.update(url: ENV['ELASTICSEARCH_URL'])
      expect(subject.client_options).to eq options
    end

    it 'allows the default client options to be overriden' do
      logger = Object.new
      options  = {
        debug: true,
        logger: logger,
        url: 'http://mytesturl.com:9200/'
      }
      subject.client_options = options

      expect(subject.client_options).to eq options
    end
  end
end
