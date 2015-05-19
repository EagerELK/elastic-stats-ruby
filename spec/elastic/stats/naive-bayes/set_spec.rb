require 'spec_helper'
require 'elastic/stats/naive-bayes/set'

describe Elastic::Stats::NaiveBayes::Set do
  subject do
    Elastic::Stats::NaiveBayes::Set.new(
      'transactions', 'training', 'category', 'subject'
    )
  end

  context '#tokens' do
    it 'works'
  end
end
