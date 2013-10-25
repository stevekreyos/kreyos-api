class Configuration
  class << self
    attr_accessor :api_endpoint
    attr_accessor :self_endpoint

    attr_accessor :mail_address
    attr_accessor :mail_port
    attr_accessor :mail_user_name
    attr_accessor :mail_password
    attr_accessor :authentication
  end
end
