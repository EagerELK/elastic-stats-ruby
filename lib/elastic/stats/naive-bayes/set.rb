require 'hashie'
require 'elastic/stats/elastic_client'

module Elastic
  module Stats
    module NaiveBayes
      # A set of documents against which statistics will be calculated
      class Set
        include ElasticClient

        attr_reader :category_field, :subject_field, :index, :type

        def initialize(index, type, category_field, subject_field)
          @index = index
          @type = type
          @category_field = category_field
          @subject_field = subject_field
        end

        # The number of documents in the set
        def count
          init_stats if @count.nil?
          @count
        end

        # All the categories with their number of documents in the set
        def categories
          init_stats if @categories.nil?
          @categories
        end

        def tokens
          @tokens ||= Hash.new { |h, k| h[k] = count_search[k]['hits']['total'] }
        end

        def token_categories
          @token_categories ||= Hash.new do |h, k|
            result = count_search[k]['aggregations']['counts']['buckets'].map do |bucket|
              { bucket['key'] => bucket['doc_count'] }
            end
            h[k] = Hash.new(0).merge(result.reduce(:merge))
          end
        end

        # Get all the tokens from the subject
        def tokenize(subject)
          # TODO: If we want to differentiate between multinominal and bernoulli
          # We need to specify what analyzer to use. multinominal does not worry
          # about uniqueness, whilst bernoulli does
          # Also:
          # Multin: Prob(Ti|C) = number of occurrences of Ti in C. So non unique
          # Bernoulli: Prob(Ti|C) = number of documents in C containing Ti
          results = analyze field: subject_field, text: subject
          results['tokens'].collect { |x| x['token'] }
        end

        # Elasticsearch client helper methods
        def search(options = {})
          client.search({ index: index, type: type }.merge(options))
        end

        def analyze(options = {})
          client.indices.analyze({ index: index }.merge(options))
        end

        private

        def init_stats
          results = Hashie::Mash.new(
            search(search_type: 'count', body: aggregation)
          )

          @count = results.hits.total
          @categories = results.aggregations.counts.buckets.map do |bucket|
            { bucket['key'] => bucket['doc_count'] }
          end
          @categories = @categories.reduce(:merge)
        end

        private

        def count_search
          @count_search ||= Hash.new{ |h, k| h[k] = search search_type: 'count', body: token_query(k) }
        end

        private

        def aggregation
          {
            aggs: {
              counts: {
                terms: {
                  field: category_field,
                  size: 200 # We're assuming there's less than 200 categories
                }
              }
            }
          }
        end

        private

        def token_query(token)
          body = Hashie::Mash.new
          body.query!.filtered!.filter!.term!
          body.query.filtered.filter.term[subject_field] = token
          body.merge aggregation
        end
      end
    end
  end
end
