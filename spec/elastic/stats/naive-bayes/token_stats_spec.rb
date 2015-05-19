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
        english: 4
      }
    }
  end

  def tokenize(subject)
    subject.downcase.split
  end
end

def subject
  @subject ||= Elastic::Stats::NaiveBayes::TokenStats.new 'is', TestSet.new
end

describe Elastic::Stats::NaiveBayes::TokenStats do
  subject do
    TokenStats.new 'is', TestSet.new
  end

  context '#count' do
    it 'returns the number of documents that contains the token'
    it 'returns the categories as an integer'
  end

  context '#categories' do
    it 'returns the categories associated with the token in the set'
    it 'returns the categories as a Hash'
  end

  context '#probability' do
    it 'returns the probability that a token is in the specified category'
    it 'returns the probability as a float'
  end

  context '#inverse' do
    it 'returns the inverse probability that a token is in the category'
    it 'returns the probability as a float'
  end
end
