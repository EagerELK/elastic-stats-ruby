require 'hashie'

module Elastic
  module Stats
    module Ranged
      def range(from, to)
        Hashie::Mash.new(
          client.search index: indices.join(','), body: query(from, to)
        ).aggregations.hits_per_minute.buckets.collect(&:doc_count)
      end
    end
  end
end
