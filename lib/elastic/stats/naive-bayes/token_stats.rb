# Read through http://www.cs.nyu.edu/faculty/davise/ai/bayesText.html
module Elastic
  module Stats
    module NaiveBayes
      # Provide statistics about a token in a specific set of data
      class TokenStats
        attr_reader :token, :set, :document

        def initialize(token, set, document)
          @token = token
          @set = set
          @document = document
        end

        # Returns the number of documents that contains the token
        def count
          set.tokens[token]
        end

        # Returns the categories associated with the token in the set as a Hash
        def categories
          set.token_categories[token]
        end

        # Returns all the words in the document |V|
        def set_tokens
          set.tokenize(document).count
        end

        # Returns the probability with laplace smoothing - Pr(W|S)
        def probability(category, smooth = 1)
          if smooth.nil?
            categories[category]) / (set.categories[category].to_f
          else
            (smooth + categories[category]) / (set.categories[category].to_f + set_tokens + smooth)
          end
        end

        # Returns the probability that a token is in the specified category - Pr(W|S)
        def probability(category)
          return 0.0 unless categories.has_key? category
          return 0.0 if set.categories[category] == 0
          categories[category] / set.categories[category].to_f
        end

        # Returns the inverse probability that a token is in the category - Pr(W|H)
        def inverse(category)
          return 0.0 unless categories.has_key? category
          return 0.0 if (set.count - set.categories[category]) == 0
          (count - categories[category]) / \
            (set.count - set.categories[category]).to_f
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
