require 'flt'
include Flt

module Elastic
  module Stats
    module NaiveBayes
      # Provide statistics about a token in a specific set of data
      # See http://burakkanber.com/blog/machine-learning-naive-bayes-1/ for an
      # explanation around the maths contained in this class
      class TokenStats
        attr_reader :token, :set

        def initialize(token, set)
          @token = token
          @set = set
        end

        # Returns the number of documents that contains the token
        def count
          set.tokens[token]
        end

        # Returns the categories associated with the token in the set as a Hash
        def categories
          set.token_categories[token]
        end

        # Returns the probability that a token is in the specified category as a DecNum
        def probability(category)
          return 0 unless categories.has_key? category
          return 0 if set.categories[category] == 0
          DecNum(categories[category]) / DecNum(set.categories[category])
        end

        # Returns the inverse probability that a token is in the category as a DecNum
        def inverse(category)
          return 0 unless categories.has_key? category
          return 0 if (set.count - set.categories[category]) == 0
          DecNum(count - categories[category]) / DecNum(set.count - set.categories[category])
        end

        # Returns the Bayes probability as a DecNum
        def bayes(category)
          return 0 if count == 0
          return 0 if (probability(category) + inverse(category)) == 0
          probability(category) / (probability(category) + inverse(category))
        end
      end
    end
  end
end
