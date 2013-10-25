class SettingsController < ApplicationController
  
  require 'open-uri'
  require 'json'
  
  include GeneralModule
  
  def settings
    data = {
      basic_info: basic_info,
      dimentions: dimentions
    }
     render :json => data
  end
  
  def basic_info
    data      = []
    @settings = WebUser.find_by_id(params[:userid])
    
    data.push({
      name: @settings['name'],
      nickname: @settings['nickname'],
      email: @settings['email'],
      birthday: @settings['birthday'],
      gender: @settings['gender']
    })
    
    return data
  end
  
  def dimentions
    data = []
    @dimentions = WebUserDimention.find_by_member_id(params[:userid])
  
    unless @dimentions['height_value'].nil?
      data.push({
        about_me: @dimentions['about_me'],
        height: {
          value: @dimentions['height_value'].gsub("\\", ""),
          unit: @dimentions['height_unit']
        },
        weight:{
          value: @dimentions['weight_value'],
          unit: @dimentions['weight_unit']
        },
        distance: @dimentions['distance'],
        country: @dimentions['country'],
        state: @dimentions['state'],
        city: @dimentions['city'],
        zip: @dimentions['zip']
      })
    else
      data.push({
        about_me: @dimentions['about_me'],
        height: {
          value: @dimentions['height_value'],
          unit: @dimentions['height_unit']
        },
        weight:{
          value: @dimentions['weight_value'],
          unit: @dimentions['weight_unit']
        },
        distance: @dimentions['distance'],
        country: @dimentions['country'],
        state: @dimentions['state'],
        city: @dimentions['city'],
        zip: @dimentions['zip']
      })
    end    
    return data  
  end
  
  def save_settings
    # begin
       # if params[:about_me].blank? || params[:fname].blank? || params[:nickname].blank? || params[:bd_day].blank? || params[:bd_year].blank? || params[:height_value].blank? || params[:weight_value].blank? || params[:country].blank? || params[:city].blank? || params[:zip].blank?
       if params[:fname].blank? || params[:nickname].blank? || params[:height_value].blank? || params[:weight_value].blank? || params[:country].blank? || params[:city].blank? || params[:zip].blank?        
        @settings = WebUser.update_user(params)
        WebUserDimention.update_user_dimention(params)
      
        render :json => {result: "Success" }
      else
        user = WebUser.find_by_sql("SELECT wu.email, wud.bv_status FROM web_users AS wu INNER JOIN web_user_dimentions AS wud ON wu.id = wud.member_id WHERE wu.id =#{params[:userid]}").first
        
        @settings = WebUser.update_user(params)
        WebUserDimention.update_user_dimention(params)
        
        unless user['bv_status'] != 0
          WebUserDimention.update_bv_status(params[:userid])
          
          ep = "#{@@end_point}/activities.json"
          uri = URI.parse(ep)
          response = Net::HTTP.post_form(uri, {"site" =>"kreyos.nesventures.net", "user" => user['email'], "activity[verb]" => "complete_profile"})
        end
        
        render :json => {result: "Success" }
      end  
    # rescue
      # render :json => {result: "Failed" }
    # end  
  end
  
  def save_profile
    if params[:profile] == 'about_me'
      # => About Me
      profile = WebUserDimention.update_all("about_me = '#{Mysql.escape_string(params[:value])}' WHERE member_id = #{params[:userid]}")  
    elsif params[:profile] == 'height'
      # => Height
      profile = WebUserDimention.update_all("height_value = '#{Mysql.escape_string(params[:value])}', height_unit = '#{params[:unit]}' WHERE member_id = #{params[:userid]}")
    elsif params[:profile] == 'weight'
      # => Weight
      profile = WebUserDimention.update_all("weight_value = '#{Mysql.escape_string(params[:value])}', weight_unit = '#{params[:unit]}' WHERE member_id = #{params[:userid]}")
    elsif params[:profile] == 'distance'
      # => Distance
      profile = WebUserDimention.update_all("distance = '#{params[:value]}' WHERE member_id = #{params[:userid]}")
    elsif params[:profile] == 'country'
      # => Country
      profile = WebUserDimention.update_all("country = '#{params[:country]}', state = '#{params[:state]}', city = '#{params[:city]}', zip = '#{params[:zip]}' WHERE member_id = #{params[:userid]}")
    elsif params[:profile] == 'complete'
      user = WebUser.find_by_id(params[:userid])
      profile = WebUserDimention.update_all("bv_status = 1 WHERE member_id = #{params[:userid]}")    
      
      #=> Complete Profile
      ep = "#{@@end_point}/activities.json"
      uri = URI.parse(ep)
      response = Net::HTTP.post_form(uri, {"site" =>"kreyos.nesventures.net", "user" => user['email'], "activity[verb]" => "complete_profile"}) 
    end
    
    if profile == 1
      render :json => WebUserDimention.find_by_member_id(params[:userid])
    else
      render :json => 0
    end
  end
  
end