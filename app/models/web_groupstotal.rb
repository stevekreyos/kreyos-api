class WebGroupstotal < ActiveRecord::Base
  
  set_table_name "web_groupstotal"
  attr_accessible :id, :runner, :biker, :walker, :cyclist
  
  def self.total_list()
    select("*")
  end

end