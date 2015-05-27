module Elastic
  module Stats
    module NaiveBayes
      # Provide statistics about a token in a specific set of data
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

        # Returns the probability that a token is in the specified category
        def probability(category)
          return 0 unless categories.has_key? category
          return 0 if set.categories[category] == 0
          categories[category] / set.categories[category].to_f
        end

        # Returns the inverse probability that a token is in the category
        def inverse(category)
          return 0 unless categories.has_key? category
          return 0 if (set.count - set.categories[category]) == 0
          (count - categories[category]) / \
            (set.count - set.categories[category]).to_f
        end

        def bayes(category)
          return 0 if count == 0
          return 0 if (probability(category) + inverse(category)) == 0
          calculated = log_protect(
            probability(category) / (probability(category) + inverse(category))
          )
          adjust(calculated)
          Math.log(1 - calculated) - Math.log(calculated)
        end

        private

        def adjust(probability, weight = 1, target = 0.5)
          ((weight * target) + (count * probability)) / (1 + count)
        end

        private

        def log_protect(probability)
          return 0.0001 if probability == 0
          return 0.9999 if probability == 1
          probability
        end
      end
    end
  end
end
