require "base64"
require "time"
require "excon"
require "uri"
require "zlib"
require 'openssl'

# open it up when needed. This will be needed when a new customer onboarded via pug.
require "securerandom"

__LIB_DIR__ = File.expand_path(File.join(File.dirname(__FILE__), ".."))
unless $LOAD_PATH.include?(__LIB_DIR__)
$LOAD_PATH.unshift(__LIB_DIR__)
end

require "podnix/api/errors"
require "podnix/api/version"
require "podnix/api/images"
require "podnix/api/servers"
require "podnix/core/config"
require "podnix/core/stuff"
require "podnix/core/text"
require "podnix/core/json_compat"
require "podnix/core/error"
require "podnix/core/images"
require "podnix/core/images_collection"
require "podnix/core/servers"
require "podnix/core/servers_collection"


#we may nuke logs out of the api
#require "megam/api/logs"

# Do you need a random seed now ?
#srand

module Podnix
  class API

    #text is used to print stuff in the terminal (message, log, info, warn etc.)
    attr_accessor :text

    HEADERS = {
      'Accept' => 'application/json',
      'Accept-Encoding' => 'gzip',
      'User-Agent' => "podnix/#{Podnix::API::VERSION}",
      'X-Ruby-Version' => RUBY_VERSION,
      'X-Ruby-Platform' => RUBY_PLATFORM
    }

    OPTIONS = {
      :headers => {},
      :host => 'api.podnix.com',
      :nonblock => false,
      :scheme => 'https'
    }

    API_VERSION1 = ""

    def text
      @text ||= Podnix::Text.new(STDOUT, STDERR, STDIN, {})
    end

    def last_response
      @last_response
    end

    # It is assumed that every API call will use an API_KEY/email. This ensures validity of the person
    # really the same guy on who he claims.
    # 3 levels of options exits
    # 1. The global OPTIONS as available inside the API (OPTIONS)
    # 2. The options as passed via the instantiation of API will override global options. The ones that are passed are :email and :api_key and will
    # be  merged into a class variable @options
    # 3. Upon merge of the options, the api_key, email as available in the @options is deleted.
    def initialize(options={})
      @options = OPTIONS.merge(options)
      @api_key = @options.delete(:api_key) || ENV['PODNIX_API_KEY']
      @email = @options.delete(:email)
      raise ArgumentError, "You must specify [:email, :api_key]" if @email.nil? || @api_key.nil?
    end

    def request(params,&block)
      start = Time.now
      text.msg "#{text.color("START", :cyan, :bold)}"
      params.each do |pkey, pvalue|
        text.msg("> #{pkey}: #{pvalue}")
      end

      begin
        response = connection.request(params, &block)
      rescue Excon::Errors::HTTPStatusError => error
        klass = case error.response.status

        when 401 then Podnix::API::Errors::Unauthorized
        when 403 then Podnix::API::Errors::Forbidden
        when 404 then Podnix::API::Errors::NotFound
        when 408 then Podnix::API::Errors::Timeout
        when 422 then Podnix::API::Errors::RequestFailed
        when 423 then Podnix::API::Errors::Locked
        when /50./ then Podnix::API::Errors::RequestFailed
        else Podnix::API::Errors::ErrorWithResponse
        end
        reerror = klass.new(error.message, error.response)
        reerror.set_backtrace(error.backtrace)
        text.msg "#{text.color("#{reerror.response.body}", :white)}"
        reerror.response.body = Podnix::JSONCompat.from_json(reerror.response.body.chomp)
        text.msg("#{text.color("RESPONSE ERR: Ruby Object", :magenta, :bold)}")
        text.msg "#{text.color("#{reerror.response.body}", :white, :bold)}"
        raise(reerror)
      end

      @last_response = response
      text.msg("#{text.color("RESPONSE: HTTP Status and Header Data", :magenta, :bold)}")
      text.msg("> HTTP #{response.remote_ip} #{response.status}")

      response.headers.each do |header, value|
        text.msg("> #{header}: #{value}")
      end
      text.info("End HTTP Status/Header Data.")

      if response.body && !response.body.empty?
        if response.headers['Content-Encoding'] == 'gzip'
          response.body = Zlib::GzipReader.new(StringIO.new(response.body)).read
        end
        text.msg("#{text.color("RESPONSE: HTTP Body(JSON)", :magenta, :bold)}")

        text.msg "#{text.color("#{response.body}", :white)}"

        begin
          response.body = Podnix::JSONCompat.from_json(response.body.chomp)
          text.msg("#{text.color("RESPONSE: Ruby Object", :magenta, :bold)}")

          text.msg "#{text.color("#{response.body}", :white, :bold)}"
        rescue Exception => jsonerr
          text.error(jsonerr)
          raise(jsonerr)
        # exception = Podnix::JSONCompat.from_json(response_body)
        # msg = "HTTP Request Returned #{response.code} #{response.message}: "
        # msg << (exception["error"].respond_to?(:join) ? exception["error"].join(", ") : exception["error"].to_s)
        # text.error(msg)
        end
      end
      text.msg "#{text.color("END(#{(Time.now - start).to_s}s)", :blue, :bold)}"
      #  text.msg "#{text.color("END(#{(Podnix::Stuff.time_ago(start))})", :blue, :bold)}"

      # reset (non-persistent) connection
      @connection.reset
      response
    end

    private

    #Make a lazy connection.
    def connection
      @options[:path] =API_VERSION1+ @options[:path]
      encoded_api_header = encode_header(@options)
      @options[:headers] = HEADERS.merge({
        'X-Podnix-HMAC' => encoded_api_header[:hmac],
        'X-Podnix-Date' => encoded_api_header[:date],
      }).merge(@options[:headers])

      #SSL certificate file paths
      #If ssl_ca_path and file specified shows error
      #Only file pass through
      #Excon.defaults[:ssl_ca_path] = "/etc/ssl/certs"
      #ENV['SSL_CERT_DIR'] = "/etc/ssl/certs"
      Excon.defaults[:ssl_ca_file] = File.expand_path(File.join(File.dirname(__FILE__), "..", "certs", "cacert.pem"))
      #ENV['SSL_CERT_FILE'] = File.expand_path(File.join(File.dirname(__FILE__), "..", "certs", "cacert.pem"))

      if !File.exist?(File.expand_path(File.join(File.dirname(__FILE__), "..", "certs", "cacert.pem")))
        text.warn("Certificate file does not exist. SSL_VERIFY_PEER set as false")
        Excon.defaults[:ssl_verify_peer] = false
      #elsif !File.readable_real?(File.expand_path(File.join(File.dirname(__FILE__), "..", "certs", "test.pem")))
      #	puts "==================> Test CER 2===============>"
      #	text.warn("Certificate file is readable. SSL_VERIFY_PEER set as false")
      #	Excon.defaults[:ssl_verify_peer] = false
      else
        text.info("Certificate found")
        Excon.defaults[:ssl_verify_peer] = true
      end

      text.info("HTTP Request Data:")
      text.msg("> HTTP #{@options[:scheme]}://#{@options[:host]}")
      @options.each do |key, value|
        text.msg("> #{key}: #{value}")
      end
      text.info("End HTTP Request Data.")
      @connection = Excon.new("#{@options[:scheme]}://#{@options[:host]}",@options)
    end

    ## encode header as per rules.
    # The input hash will have
    # :api_key, :email, :body, :path
    # The output will have
    # :hmac
    # :date
    # (Refer https://Github.com/indykish/megamplay.git/test/AuthenticateSpec.scala)
    def encode_header(cmd_parms)
      header_params ={}
      body_digest = OpenSSL::Digest::MD5.digest(cmd_parms[:body])
      body_base64 = Base64.encode64(body_digest)

      current_date = Time.now.strftime("%Y-%m-%d %H:%M")

      data="#{current_date}"+"\n"+"#{cmd_parms[:path]}"+"\n"+"#{body_base64}"

      digest  = OpenSSL::Digest::Digest.new('sha1')
      movingFactor = data.rstrip!
      hash = OpenSSL::HMAC.hexdigest(digest, @api_key, movingFactor)
      final_hmac = @email+':' + hash
      header_params = { :hmac => final_hmac, :date => current_date}
    end
  end

end
