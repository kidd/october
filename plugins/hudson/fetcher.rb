require 'httpclient'
require 'httpclient/include_client'

class Hudson
  class Fetcher
    class HTTPError < StandardError
      def initialize(response)
        message = "Failed to fetch #{response.http_header.request_uri} status:#{response.status} reason:#{response.reason}"
        super(message)
      end
    end

    extend HTTPClient::IncludeClient
    include_http_client do |client|
      user = ENV['HUDSON_USER'].presence
      pass = ENV['HUDSON_PASS'].presence

      if user or pass
        client.set_auth base_url, user, pass
      end
    end

    class_attribute :base_url, :job_url, :config_url

    self.base_url = "http://localhost:8080"
    if ENV['HUDSON_USER']
      self.base_url = "https://hudson.3scale.net"
    end
    self.job_url  = "/job/<job>/<test_run>/consoleText"

    self.config_url = "/job/<job>/config.xml"

    delegate :base_url, :job_url, :config_url, :to => 'self.class'

    attr_reader :test_run, :url

    def initialize test_run, options = {}
      @test_run = test_run

      @url = full_url(job_url)

      @config_url = full_url(config_url)

    end

    def response
      @response ||= self.class.http_client.get(url).tap do |response|
        verify_response!(response)
      end
    end

    def config
      @config ||= begin
        response = self.class.http_client.get(@config_url)
        verify_response!(response)
        Nokogiri::XML.parse(response.body)
      end
    end

    def verify_response!(response)
      unless response.ok?
        raise HTTPError, response
      end
    end

    def full_url(part)
      (base_url + part).
          gsub('<job>', @test_run.job.to_s).
          gsub('<test_run>', @test_run.number.to_s).freeze
    end
  end
end
