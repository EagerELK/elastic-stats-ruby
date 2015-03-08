require 'elastic/stats/elastic_client'
require 'hashie'
require 'statsample'

module Elastic
  module Stats
    # Utility to determine the KolmogorovSmirnov difference between to sets of
    # data fetched from Elasticsearch
    class KS
      include ElasticClient

      attr_accessor :logger, :query
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

        options = default_options.update(options)

        @to       = options.delete(:to)
        @span     = options.delete(:span)
        @interval = options.delete(:interval)
        @field    = options.delete(:field)
        @offset   = options.delete(:offset)

        @indices = [indices] unless @indices.is_a? Array
        @from    = @to - @span
      end

      def fetch(confidence = 0.05)
        current  = range(@from, @to)
        previous = range(@from - @offset, @to - @offset)

        difference = Statsample::Test::KolmogorovSmirnov.new(
          current, previous
        ).d

        comparison = calculate(current, previous, confidence)
        {
          confidence: confidence, comparison: comparison,
          difference: difference, different?: (difference > comparison)
        }
      end

      def calculate(current, previous, confidence)
        MULTIPLIERS[confidence] * Math.sqrt(
          (
            (current.count + previous.count).to_f /
            (current.count * previous.count)
          )
        )
      end

      private

      def range(from, to)
        Hashie::Mash.new(
          client.search index: indices.join(','), body: body(from, to)
        ).aggregations.hits_per_minute.buckets.collect(&:doc_count)
      end

      def body(from, to)
        body = Hashie::Mash.new
        body.query = query if query
        body.aggregations!.hits_per_minute!.date_histogram = aggregate(from, to)
        body
      end

      private

      def aggregate(from, to)
        {
          field: field, interval: interval, min_doc_count: 0,
          extended_bounds: {
            min: (from * 1000),
            max:   (to * 1000)
          }
        }
      end

      private

      def default_options
        {
          to: Time.new.to_i,
          span: (60 * 60 * 12),
          interval: '1h',
          field: '@timestamp',
          offset: (60 * 60 * 24 * 7)
        }
      end
    end
  end
end
