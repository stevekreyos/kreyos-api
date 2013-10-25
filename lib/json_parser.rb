require 'rubygems'
require 'active_support/json'
require 'net/http'

class JsonParser
  
  @@jsonstr=""
  
  class << self

    def new(urlstr = "",post_data={},usedef = true,method="post")
      if urlstr != ""
          read_json(urlstr,usedef,true,post_data,method)
      end
    end

    def read_json(urlstr,usedef = true, returns=true, post_data={}, method="post")

      urlstr = "#{Configuration.api_endpoint}/" + urlstr
      
      if method == "post"
        resp = Net::HTTP.post_form(URI.parse(URI.encode(urlstr)),post_data)
      elsif method == "get"
          resp = Net::HTTP.get_response(URI.parse(URI.encode(urlstr)))
      else
        resp = "Invalid method"
      end
    
      begin
        data= ActiveSupport::JSON.decode(resp.body)
      rescue
        begin
          data=resp.body
        rescue
          data="error"
        end
      end

      if returns==true
        return data
      end

    end

    def jsonstring
      return @@jsonstr
    end
    
  end
end