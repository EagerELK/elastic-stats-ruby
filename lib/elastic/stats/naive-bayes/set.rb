require 'hashie'
require 'elastic/stats/elastic_client'

module Elastic
  module Stats
    module NaiveBayes
      # A set of documents against which statistics will be calculated
      class Set
        include ElasticClient

        attr_reader :category_field, :subject_field
        attr_reader :count, :categories, :tokens, :token_categories

        def initialize(index, type, category_field, subject_field)
          @index = index
          @type = type
          @category_field = category_field
          @subject_field = subject_field

          init_stats
          init_caches
        end

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

        def init_caches
          @tokens ||= Hash.new { |h, k| h[k] = initialize_token(k) }

          @token_categories ||= Hash.new { |h, k| h[k] = initialize_token(k) }
        end

        def tokenize(subject)
          results = analyze field: subject_field, text: subject
          results['tokens'].collect { |x| x['token'] }
        end

        private

        def initialize_token(token)
          result = search search_type: 'count', body: token_query(token)

          @tokens[token] = result['hits']['total']
          result = result['aggregations']['counts']['buckets'].map do |bucket|
            { bucket['key'] => bucket['doc_count'] }
          end
          Hash.new(0).merge(result.reduce(:merge))
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
          body.query!.filtered!.filter!.term!.description = token
          body.merge aggregation
        end
      end
    end
  end
end
