require 'elastic/stats/elastic_client'
require 'elastic/stats/naive-bayes/token_stats'

module Elastic
  module Stats
    module NaiveBayes
      # Utility to perform Naive Bayes category predictions on text
      class Predictor
        include ElasticClient

        attr_reader :prior_set
        attr_writer :adjust

        def initialize(prior_set)
          @prior_set = prior_set
        end

        def guess(subject)
          scores = {}
          prior_set.categories.keys.each do |category|
            scores[category] = score(subject, category)
          end
          Hash[scores.sort_by { |label, score| -score }]
        end

        def score(subject, category)
          # Calculate the propability for each token in this category
          log_sum = tokenize(subject).reduce(0) do |sum, token|
            stats = TokenStats.new(token, prior_set, subject)
            sum + stats.bayes(category)
          end

          1 / (1 + Math.exp(log_sum))
        end

        def tokenize(subject)
          # TODO: Using a whole document as a hash key is probably a bad idea. Maybe just hash it?
          @tokenize ||= Hash.new { |h, k| h[k] = prior_set.tokenize k }
          @tokenize[subject]
        end
      end
    end
  end
end
