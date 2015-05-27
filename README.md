# Elastic::Stats

## Installation

Add this line to your application's Gemfile:

    gem 'elastic-stats'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install elastic-stats

## Usage

### KS

~~~
require 'elastic/stats/ks'
require 'logger'

# Set the URL
ENV['ELASTICSEARCH_URL'] = 'https://test.eagerelk.com/'
# This is perfect for logstash stats
stats = Elastic::Stats::KS.new 'logstash-2015.03.05'
# Set some client options to enable logging and debugging
stats.client_options = {
  debug: true,
  logger: Logger.new(STDOUT),
  request_body: true,
  transport_options: {
    ssl: { verify: false }
  }
}
# Add extra filters to the query
stats.query = { filtered: { filter: { fquery: { query: { query_string:{ query: "type:(\"crimson_db\")"}}}}}}

# Fetch and output the stats
puts stats.fetch.inspect
~~~

### Naive Bayes Filter

TODO

## Contributing

1. Fork it ( https://github.com/eagerelk/elastic-stats-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
