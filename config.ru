require 'net/http'
require 'uri'

socialify = Proc.new do |env|
  if env['REQUEST_URI'].length <= 4
    return [301, {"Content-Type" => "text/html"}, '/www.yelp.com/biz/rom-mai-thai-seattle'] 
  end
  
  uri = URI.parse("http:/#{env['REQUEST_URI']}")
  response = Net::HTTP.get_response(uri)

  wordlist = %w(amazing appalling awful excellent fantastic fine good 
    horrible impressive incredible nice outstanding superb stupid terrible wonderful)
  response.body.gsub!(Regexp.new(wordlist.collect { |word| " most #{word} " }.join('|')), ' greatest ')
  response.body.gsub!(Regexp.new(wordlist.collect { |word| " more #{word} " }.join('|')), ' greater ')
  response.body.gsub!(Regexp.new(wordlist.join('|') + "\W"), 'great')

  [200, {"Content-Type" => "text/html"}, response.body ]
end

builder = Rack::Builder.new do
  use Rack::CommonLogger
  
  map '/' do
    run socialify
  end
end

Rack::Handler::Mongrel.run builder, :Port => 9292
