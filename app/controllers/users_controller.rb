class UsersController < ApplicationController
  
  require 'open-uri'
  require 'json'
  
  include GeneralModule
  
  #before_filter :setup_email, :only => ["contact_us"]
  
  def facebook_authentication
    begin
      data = 0
      user = WebUser.find_by_email(params[:email])
      
      if user.nil?
        data = register(params[:provider], params[:uid], params[:name], params[:email], params[:oauth_token], params[:gender], params[:birthday], params[:nickname])
      else
        data = user
        check_pending_friends(user['id'], user['bv_player_id'], user['email'])
      end
    rescue
      data = 1
    end
    
    render :json => data
  end
  
  def register(provider, uid, name, email, oauth_token, gender, birthday, nickname)
    begin
      #data = 0
      #order_id = Activity.find_by_sql("SELECT * FROM activities WHERE order_id = #{params[:order_id]} AND order_id_status = 0").first
      
      @new_date = birthday.to_s.gsub("/", "-")
      @month = @new_date.to_s.split('-')[0]
      @day = @new_date.to_s.split('-')[1]
      @year = @new_date.to_s.split('-')[2]
      @formatted_date = "#{@year}-#{@month}-#{@day}"
           
      data = WebUser.create_with_omniauth_facebook(provider, uid, name, email, oauth_token, gender, @formatted_date, nickname)
      update_order_id = Activity.update_all("order_id_status = 1", :order_id => params[:order_id])
      
      # => Add ID to web_user_dimentions table
      WebUserDimention.create_user_dimention(data['id'])
      
      # => Add to badgeville
      #create_user(data['name'], data['email'])
      
      # => Add to Infusionsoft
      Infusionsoft.contact_add({:FirstName => name.split(' ')[0], :LastName => name.split(' ')[1], :Email => email})
      
      # => Check if there are peding friends
      check_pending_friends(data['id'], data['bv_player_id'], data['email'])       
    rescue
     data = 1
    end
    
    return data
  end
  
  def get_user_info
    @user = WebUser.find_by_id(params[:userid])
    render :json => @user
  end
  
  def contact_us
    UserMailer.contact_us(params[:email], params[:subject], params[:message]).deliver
    render_json("Message sent")
  rescue
    @error_response = { "errors" => "Message not sent" }
    return render_json(@error_response, 400)
  end
  
  def create_user(username, email)
    ep = "#{@@end_point}/users.json"
    ep_activity = "#{@@end_point}/activities.json"
    
    # => Create user on badgeville
    uri = URI.parse(ep)
    response = Net::HTTP.post_form(uri, {"user[name]" => username, "user[email]" => email})
    
    
    # => Assign reward "REGISTER" to user
    reg_uri = URI.parse(ep_activity)
    reg_response = Net::HTTP.post_form(reg_uri, {"site" =>"kreyos.nesventures.net", "user" => email, "activity[verb]" => "register"})
    json_obj = JSON.parse(reg_response.body) 
    
    
    # => Save badgeville id and player_id on database
    WebUser.update_all("bv_id ='"+ json_obj['rewards'][0]['user_id'] +"', bv_player_id ='" + json_obj['rewards'][0]['player_id'] +"'", :email => email)
  end
  
  def check_profile
    my_profile = WebUserDimention.find_by_member_id(params[:userid])
    render :json => my_profile
  end

 
end