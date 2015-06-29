require 'spec_helper'
require 'elastic/stats/naive-bayes/token_stats'

# Testing Set
class TestSet
  def count
    10
  end

  def categories
    {
      afrikaans: 4,
      english: 5,
      french: 1
    }
  end

  def tokens
    {
      'is' => 7
    }
  end

  def token_categories
    {
      'is' => {
        afrikaans: 4,
        english: 3
      }
    }
  end

  def tokenize(subject)
    subject.downcase.split
  end
end

describe Elastic::Stats::NaiveBayes::TokenStats do
  let :test_set do
    TestSet.new
  end

  let :test_token do
    'is'
  end

  let :test_category do
    'afrikaans'
  end

  subject do
    Elastic::Stats::NaiveBayes::TokenStats.new test_token, test_set
  end

  context '#count' do
    it 'returns the categories as an integer' do
      expect(subject.count).to be_an(Integer)
    end

    it 'returns the number of documents that contains the token' do
      expect(subject.count).to be 7
    end
  end

  context '#categories' do
    it 'returns the categories as a Hash' do
      expect(subject.categories).to be_a(Hash)
    end

    it 'returns the categories associated with the token in the set' do
      expect(subject.categories).to eq test_set.token_categories[test_token]
    end
  end

  context '#probability' do
    it 'returns the probability as a float' do
      expect(subject.probability(test_category)).to be_a(Float)
    end

    it 'returns the probability that a token is in the specified category' do
      expect(subject.probability(test_category)).to eq
    end
  end

  context '#inverse' do
    it 'returns the probability as a float' do
      expect(subject.probability(test_category)).to be_a(Float)
    end

    it 'returns the inverse probability that a token is in the category'
  end
end
