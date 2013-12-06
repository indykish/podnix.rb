require File.expand_path("#{File.dirname(__FILE__)}/../lib/podnix/api")

require 'rubygems'
gem 'minitest' # ensure we are using the gem version
require 'minitest/autorun'
require 'time'

SANDBOX_HOST_OPTIONS = {
      :scheme => 'https',
  :host => 'api.podnix.com',
      :nonblock => false,
   :port => 443
   
}

  def nested_merge(other_hash={})
    merge(other_hash) do |key, oldval, newval|
      if oldval.is_a? Hash
        oldval.nested_merge(newval)
      else
        newval
      end
    end
  end
  
def podnix(options={})  
s_options = SANDBOX_HOST_OPTIONS.merge({
  :api_key => sandbox_apikey  
}) 
  options = s_options.merge(options)
  mg=Podnix::API.new(options)  
end

def sandbox_apikey
  ENV['PODNIX_API_KEY']
end


