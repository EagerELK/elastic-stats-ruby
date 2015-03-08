require 'elastic/stats/elastic_client'
require 'hashie'
require 'statsample'

module Elastic
  module Stats
    class KS
      include ElasticClient

      attr_accessor :logger
      attr_writer :debug, :query
      attr_reader :indices, :to, :from, :span, :interval, :field

      MULTIPLIERS = {
        0.001 => 1.95,
        0.005 => 1.73,
        0.01 => 1.63,
        0.025 => 1.48,
        0.05 => 1.36,
        0.10 => 1.22
      }


      # indices should include all possible indices.
      def initialize(indices, options = {})
        @indices  = indices

        @to       = options.delete(:to)       || Time.new.to_i
        @span     = options.delete(:span)     || (60 * 60 * 12)
        @interval = options.delete(:interval) || '1h'
        @field    = options.delete(:field)    || '@timestamp'
        @offset   = options.delete(:offset)   || (60 * 60 * 24 * 7)

        @indices = [indices]  unless @indices.is_a? Array
        @to      = @to.to_i   if @to.respond_to?(:to_i)
        @from    = @to - @span
      end

      def fetch(confidence = 0.05)
        current  = range(@from, @to)
        previous = range(@from - @offset, @to - @offset)

        difference = Statsample::Test::KolmogorovSmirnov.new(current, previous).d

        comparison = MULTIPLIERS[confidence] * Math.sqrt(
          ((current.count + previous.count).to_f / (current.count * previous.count))
        )

        {
          confidence: confidence, comparison: comparison,
          difference: difference, different?: (difference > comparison)
        }
      end

      def range(from, to)
        Hashie::Mash.new(
          client.search index: indices.join(','), body: query(from, to)
        ).aggregations.hits_per_minute.buckets.collect(&:doc_count)
      end

      def query(from, to)
        @query = Hashie::Mash.new
        @query.aggregations!.hits_per_minute!.date_histogram = {
          field: field,
          interval: interval,
          min_doc_count: 0,
          extended_bounds: {
            min: (from * 1000),
            max:   (to * 1000)
          }
        }
        @query
      end

      def debug?
        @debug ||= ENV['DEBUG']
      end
    end
  end
end
