require 'spec_helper'
require 'eager/stats/ks'

describe Eager::Stats::KS do
  it 'has an array of indices' do
    ks = Eager::Stats::KS.new('logstash-2015.12.12')
    expect(ks.indices).to be_a Array
  end

  it 'has sane defaults' do
    ks = Eager::Stats::KS.new('logstash-2015.12.12')
    now = Time.new
    expect(ks.to).to be_within(2).of(now.to_i)
    expect(ks.from).to eq ks.to - (60 * 60)
    expect(ks.interval).to eq '1m'
    expect(ks.field).to eq '@timestamp'
  end

  it 'accepts various options' do
    now = Time.new - 120
    options = {
      to: now,
      span: (60 * 60 * 24),
      interval: '5m',
      field: '@mytimefield'
    }
    ks = Eager::Stats::KS.new('logstash-2015.12.12', options)
    expect(ks.to).to eq now.to_i
    expect(ks.from).to eq (ks.to.to_i - (60 * 60 * 24))
    expect(ks.interval).to eq '5m'
    expect(ks.field).to eq '@mytimefield'
  end

  it 'fetches the KS difference and other stats' do
    WebMock.stub_request(:get, 'http://localhost:9200/fake/_search').
      to_return(
        body: fixture('successful_search.json'),
        headers: {'Content-Type' => 'text/json' }
      )

    ks = Eager::Stats::KS.new('fake')
    ks.client_options = {
      url: 'http://localhost:9200',
      log: false
    }
    result = ks.fetch

    expect(result).to have_key :difference
    expect(result).to have_key :different?
    expect(result).to have_key :confidence
    expect(result).to have_key :check
  end

  it 'buiilds the search query correctly'

  fit 'calculates the KS difference' do
    ENV['ELASTICSEARCH_URL'] = 'https://kibana:Open%20kibana!@search.tutuka.com:443'
    ks_stats = Eager::Stats::KS.new('logstash-2015.03.05')
    ks_stats.client_options = {
      transport_options: {
        ssl: { verify: false }
      }
    }
    puts ks_stats.fetch.inspect
    puts ks_stats.inspect
  end
end
