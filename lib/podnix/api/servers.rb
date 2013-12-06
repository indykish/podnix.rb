module Podnix
  class API

    # GET /servers
    def get_servers
      @options = {:path => '/servers/list',:body => ""}.merge(@options)

      request(
        :expects  => 200,
        :method   => :get,
        :body     => @options[:body]
      )
    end

    def get_server(query)
      @options = {:path => "/servers/list",:body => ""}.merge(@options)
      @options[:query]=@options[:query].merge(query)
      request(
        :expects  => 200,
        :method   => :get,
        :body     => @options[:body]
      )
    end

    def add_server(new_server)
#https://api.podnix.com/servers/add?&name=test&model=1&image=2&password=Secret123&ssd=1&storage=10&key=123-znsbKicQwKl4tZHQOXo3Olwls8BOrR3O

	@options = { :path => "/servers/add",:body => ""}.merge(@options)
	     @options[:query] = @options[:query].merge(new_server)
      request(
        :expects  => 201,
        :method   => :post,
        :body     => @options[:body]
      )
    end
    
    def start_server(server_id)
      @options = {:path => "/servers/start",
        :body => ""}.merge(@options)
      @options[:query]=@options[:query].merge(server_id)
      request(
        :expects  => 200,
        :method   => :post,
        :body     => @options[:body]
      )
    end
    

    #Yet to be tested
    # DELETE /nodes/:node_id
    def delete_server(server_id)
      @options = {:path => "/servers/delete",
        :body => ""}.merge(@options)
      @options[:query]=@options[:query].merge(server_id)
      request(
        :expects  => 200,
        :method   => :delete,
        :body     => @options[:body]
      )
    end
    
    def stop_server(server_id)
      @options = {:path => "/servers/stop?id=#{server_id}",
        :body => ""}.merge(@options)
      @options[:query]=@options[:query].merge(server_id)
      request(
        :expects  => 200,
        :method   => :post,
        :body     => @options[:body]
      )
    end

  end
end
