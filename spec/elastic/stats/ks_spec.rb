require 'spec_helper'
require 'elastic/stats/ks'

describe Elastic::Stats::KS do
  it 'has an array of indices' do
    ks = Elastic::Stats::KS.new('logstash-2015.12.12')
    expect(ks.indices).to be_a Array
  end

  it 'has sane defaults' do
    ks = Elastic::Stats::KS.new('logstash-2015.12.12')
    now = Time.new
    expect(ks.to).to be_within(2).of(now.to_i)
    expect(ks.from).to eq ks.to - (60 * 60 * 12)
    expect(ks.interval).to eq '1h'
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
    ks = Elastic::Stats::KS.new('logstash-2015.12.12', options)
    expect(ks.to).to eq now
    expect(ks.from).to eq(ks.to - (60 * 60 * 24))
    expect(ks.interval).to eq '5m'
    expect(ks.field).to eq '@mytimefield'
  end

  context 'fetch' do
    before(:all) do
      WebMock.enable!
    end

    after(:all) do
      WebMock.disable!
    end

    subject do
      WebMock.stub_request(:get, 'http://localhost:9200/fake/_search')
        .to_return(
          body: fixture('successful_search.json'),
          headers: { 'Content-Type' => 'text/json' }
        )

      ks = Elastic::Stats::KS.new('fake')
      ks.client_options = {
        url: 'http://localhost:9200',
        log: false
      }
      ks.fetch
    end

    it 'fetches the KS difference stat' do
      expect(subject).to have_key :difference
      expect(subject[:difference]).to eq 0
    end

    it 'fetches the KS different boolean' do
      expect(subject).to have_key :different?
      expect(subject[:different?]).to be false
    end

    it 'fetches the KS confidence level' do
      expect(subject).to have_key :confidence
      expect(subject[:confidence]).to eq 0.05
    end

    it 'fetches the KS comparison value' do
      expect(subject).to have_key :comparison
      expect(subject[:comparison]).to eq 0.9616652224137048
    end
  end

  context 'query' do
    it 'has no default query' do
      ks = Elastic::Stats::KS.new('logstash-2015.12.12')

      expect(ks.query).to be_nil
    end

    it 'allows for the query to be set' do
      ks = Elastic::Stats::KS.new('logstash-2015.12.12')
      query = { 'term' => { 'user' => 'eagerelk' } }
      ks.query = query

      expect(ks.query).to eq query
    end
  end
end
