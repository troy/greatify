require 'net/http'
require 'uri'

run lambda { |env|
  if env['REQUEST_URI'].length <= 4
    return [301, {'Location' => 'http://greatify.heroku.com/www.yelp.com/biz/art-of-the-table-seattle',
                  'Content-Type' => 'text/html'}, {}] 
  end
  
  uri = URI.parse("http:/#{env['REQUEST_URI']}")
  response = Net::HTTP.get_response(uri)

  wordlist = %w(amazing appalling awful excellent fantastic fine good 
    horrible impressive incredible nice outstanding superb stupid terrible wonderful)
  response.body.gsub!(Regexp.new(wordlist.collect { |word| " most #{word} " }.join('|')), ' greatest ')
  response.body.gsub!(Regexp.new(wordlist.collect { |word| " more #{word} " }.join('|')), ' greater ')
  response.body.gsub!(Regexp.new(wordlist.join('|') + "\W"), 'great')

  [200, {"Content-Type" => "text/html"}, response.body ]
}
