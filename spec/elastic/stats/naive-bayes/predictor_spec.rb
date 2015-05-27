require 'spec_helper'
require 'elastic/stats/naive-bayes/set'

describe Elastic::Stats::NaiveBayes::Set do
  subject do
    Elastic::Stats::NaiveBayes::Set.new('transactions', 'training', 'category')
  end

  context '#tokens' do
    it 'returns an array of tokens from the given string' do
      expect(subject.tokenize('one two three')).to eq(['one', 'two', 'three'])
    end
  end
end
