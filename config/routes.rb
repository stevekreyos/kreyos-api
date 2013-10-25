Api::Application.routes.draw do

  #users
  match "users/facebook"              => "users#facebook_authentication"
  match "users/get_user_info/:userid" => "users#get_user_info" 
  match "contact/us"                  => "users#contact_us"
  match "paying_customer"             => "users#if_paying_customer"
  match "infusionsoft"                => "users#infusionsoft"
  match "users/player/:id"            => "users#get_name"
  match "users/order_id"              => "users#register"
  match "users/check/profile/:userid"  => "users#check_profile"
  
  #dashboard
  match "dashboard" => "dashboard#show_all"
  match "dashboard/save_goals/:userid" => "dashboard#save_goals"
  match "check_goal_expiration" => "dashboard#check_goal_expiration"
  match "goal_info"                         => "dashboard#goal_info"
  match "dashboard/save_edit_goals/:userid" => "dashboard#save_edit_goals"
  match "dashboard/delete_goal"             => "dashboard#delete_goal"
  
  #friends
  match "friends"                               => "friends#fb_friends"
  match "friends/invite/list"                   => "friends#fb_invite_friends"
  match "friends/get_contact_list"              => "friends#get_contacts"
  match "friends/fb_invite_friends_achievement" => "friends#fb_invite_friends_achievement"
  match "friends/send_email_invitation"         => "friends#send_email_invitation"
  match "friends/save_friend"                   => "friends#save_friend"
  match "friends/delete"                        => "friends#delete_friends"
  
  #profile
  match "profile/:userid" => "profile#profile"
  match "profile/:unit/max/:member_id"          => "profile#fastest_mile"
  match "profile/:unit/min/:member_id"          => "profile#longest_run"
  
  #activities
  match "activities/:metric" => "activities#show_all"
  match "activities/user/data" => "activities#user_data"
  
  # => Settings
  match "settings/:userid"      => "settings#settings"
  match "settings/save/:userid" => "settings#save_settings"
  match "attributes/save"  => "settings#save_profile"
  
  # => Badges
  match "badges" => "badges#badges"
  
  #badgeville
  match "badgeville/users.json"               => "badgeville#show_all_users"
  match "badgeville/players.json"             => "badgeville#show_all_players"
  match "badgeville/player_info.json"         => "badgeville#show_player_by_email"
  match "badgeville/activities.json"          => "badgeville#show_all_activities"
  match "badgeville/leaderboards.json"        => "badgeville#show_all_leaderboards"
  match "badgeville/rewards.json"             => "badgeville#show_all_rewards"
  match "badgeville/reward_definitions.json"  => "badgeville#show_all_reward_definitions"
  match "badgeville/levels.json"              => "badgeville#show_all_levels"
  match "badgeville/teams.json"               => "badgeville#show_all_teams"
  match "badgeville/activitiies/by/user"      => "badgeville#activities_by_user"
  match "badgeville/reward/:type/:userid"     => "badgeville#rewards"
  
  match "badgeville/infusionsoft"             => "badgeville#infusionsoft"

end
