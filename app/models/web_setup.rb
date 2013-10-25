class WebSetup < ActiveRecord::Base
  
  set_table_name "core_config_data"
  attr_accessible :config_id, :scope, :path, :value
  
  def self.email
    select("value")
    .find(:all, :conditions => ["path = 'system/smtpsettings/username'"])
  end
  
  def self.password
    select("value")
    .find(:all, :conditions => ["path = 'system/smtpsettings/password'"])
  end

  def self.host
    select("value")
    .find(:all, :conditions => ["path = 'system/smtpsettings/host'"])
  end
  
  def self.port
    select("value")
    .find(:all, :conditions => ["path = 'system/smtpsettings/port'"])
  end
  
  def self.ssl
    select("value")
    .find(:all, :conditions => ["path = 'system/smtpsettings/ssl'"])
  end

end