require 'net/http'
require 'uri'

run lambda { |env|
  if env['REQUEST_URI'].length <= 4
    return [301, {'Location' => '/seattle.citysearch.com/profile/40842072/seattle_wa/matador.html',
                  'Content-Type' => 'text/html'}, {}] 
  end
  
  uri = URI.parse("http:/#{env['REQUEST_URI']}")
  response = Net::HTTP.get_response(uri)

  wordlist = %w(amazing appalling awful excellent fantastic fine good 
    horrible impressive incredible nice outstanding superb stupid terrible wonderful)
  response.body.gsub!(Regexp.new(wordlist.collect { |word| " most #{word} " }.join('|')), ' greatest ')
  response.body.gsub!(Regexp.new(wordlist.collect { |word| " more #{word} " }.join('|')), ' greater ')
  response.body.gsub!(Regexp.new(wordlist.join('|') + "\W"), 'great')

  # obvious relative paths
  response.body.gsub!(" src=\"/", " src=\"#{url.scheme}://#{uri.host}/")
  response.body.gsub!(" href=\"/", " href=\"#{url.scheme}://#{uri.host}/")

  [200, {"Content-Type" => "text/html"}, response.body ]
}
