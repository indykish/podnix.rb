module Podnix
  class API

    # GET /servers
    def get_models
      @options = {:path => '/models/list',:body => ""}.merge(@options)

      request(
        :expects  => 200,
        :method   => :get,
        :body     => @options[:body]
      )
    end   

    

  end
end
