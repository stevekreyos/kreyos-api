class FriendsController < ApplicationController
  require 'open-uri'
  require 'json'
  
  include GeneralModule
  
  def catchNil(data)
    return nil if data.nil?
    return JSON.parse(open(data).read)
  end
  
  def fb_friends
    user = WebUser.find_by_id(params[:userid])
    check_pending_friends(user['id'], user['bv_player_id'], user['email'])
    your_friends = WebUser.get_friend_list(params[:userid])
    
    render :json => your_friends
  end  
  
  def fb_invite_friends
    #@fb_friends = JSON.parse(open("https://graph.facebook.com/#{user['uid']}/friends?access_token=#{user['oauth_token']}").read)
    # user        = WebUser.find_by_id(params[:userid])
    # url         = "https://graph.facebook.com/fql?q=SELECT uid, name, birthday_date FROM user WHERE uid IN (SELECT uid1 FROM friend WHERE uid2 = me() ) AND not is_app_user&access_token=#{user['oauth_token']}"
    # response    = URI.parse(URI.encode(url.strip))
    # fb_friends  = JSON.parse(open(response).read)
#     
    # render :json => fb_friends
  end
  
  def fb_invite_friends_achievement
    user         = WebUser.find_by_id(params[:userid])
    ep_activity  = "#{@@end_point}/activities.json"
    reg_uri      = URI.parse(ep_activity)
    reg_response = Net::HTTP.post_form(reg_uri, {"site" =>"kreyos.nesventures.net", "user" => user['email'], "activity[verb]" => "invite_friends"})
    json_obj     = JSON.parse(reg_response.body) 
    
    render :json => json_obj
  end
  
  
  def get_contacts
    con      = []
    email    = params[:email]
    password = params[:password]
    type     = params[:email_type]
    
    if type == 'yahoo'
      @imported_contacts = Contacts.new(:yahoo, email, password).contacts
    elsif type == 'gmail'
      @imported_contacts = Contacts.new(:gmail, email, password).contacts
    elsif type == 'hotmail'
      @imported_contacts = Contacts.new(:hotmail, email, password).contacts
    end
    
     begin 
      @imported_contacts.each do |contact|
        con.push(contact[1]) 
      end
     rescue
        con.push('Invalid username or password')
     end
      
      render :json => con
  end
  
  def send_email_invitation
    invitation = WebEmailInvites.check_if_email_exist(params[:email], params[:userid]) || WebEmailInvites.save_invites(params[:email], params[:userid])
    
    if !invitation.nil?
      msg = {result: "Success"}
    else
      msg = {result: "Failed"}  
    end
    
    render :json => msg
  end
  
  def save_friend
    @friend = WebFriend.check_if_friend_exist(params[:userid], params[:friend_uid]) || WebFriend.save_friend_uid(params[:userid], params[:friend_uid])
    render :json => @friend
  end
  
  def delete_friends
    
    friend_to_be_deleted = WebUser.find_by_sql("SELECT * FROM web_users WHERE email = '#{params[:friend_uid]}'").first
    deleter = WebUser.find_by_sql("SELECT * FROM web_users WHERE id = #{params[:userid]}").first
    
    @query = "DELETE FROM web_friends WHERE member_id = #{params[:userid]} AND invitee_email IN ('#{params[:friend_uid]}')"
    ActiveRecord::Base.connection.execute(@query)
    
    @query2 = @query = "DELETE FROM web_friends WHERE member_id = #{friend_to_be_deleted['id']} AND invitee_email IN ('"+ deleter['email'] +"')" 
    ActiveRecord::Base.connection.execute(@query2)
  end
end