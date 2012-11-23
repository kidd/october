require 'httpclient'
require 'httpclient/include_client'

class Fortune
  extend HTTPClient::IncludeClient
  include_http_client

  include October::Plugin

  match /fortune?$/, method: :fortune

  FORTUNE_API = 'http://www.fortunefortoday.com/getfortuneonly.php'

  register_help 'fortune', 'fortune YO!'
  def fortune(m)
    response = self.class.http_client.get(FORTUNE_API)
    m.reply response.body.strip
  end
end
