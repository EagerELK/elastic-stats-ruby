require 'spec_helper'
require 'elastic/stats/naive-bayes/set'
require 'webmock'

describe Elastic::Stats::NaiveBayes::Set do
  subject do
    set = Elastic::Stats::NaiveBayes::Set.new(
      'transactions', 'training', 'category', 'subject'
    )
    set.client_options = {url: 'http://localhost:9200'}
    set
  end

  context '#initialize' do
    it 'sets the passed parameters' do
      set = Elastic::Stats::NaiveBayes::Set.new(
        'transactions', 'training', 'category', 'subject'
      )

      expect(set.index).to eq 'transactions'
      expect(set.type).to eq 'training'
      expect(set.category_field).to eq 'category'
      expect(set.subject_field).to eq 'subject'
    end
  end

  context '#count' do
    it 'initializes the count on first call' do
      WebMock.stub_request(:get, 'http://localhost:9200/transactions/training/_search?search_type=count')
        .with(body: fixture('set_search_request.json'))
        .to_return(
          body: fixture('successful_set.json'),
          headers: { 'Content-Type' => 'text/json' }
        )

      subject.count
    end

    it 'uses the cached count on subsequent calls'
  end

  context '#categories' do
    it 'initializes the categories on first call'
    it 'uses the cached categories on subsequent calls'
  end

  context '#tokens' do
    it 'initializes the tokens on first call'
    it 'uses the cached tokens on subsequent calls'
  end

  context '#token_categories' do
    it 'initializes the token_categories on first call'
    it 'uses the cached token_categories on subsequent calls'
  end

  context '#tokenize' do
    it 'uses the Elasticsearch client to tokenize a string' do
      test_string = 'one two three'

      client = double
      indices = double
      params = {
        index: 'transactions',
        type: 'training',
        field: 'subject',
        text: test_string
      }
      expect(indices).to receive(:analyze).with(params).and_return('tokens' => [])
      expect(client).to receive(:indices).and_return(indices)

      subject.client = client
      subject.tokenize(test_string)
    end
  end
end
