#24042017 - Kristof VD Ouweland - Adding the LDAP provider 
Rails.application.config.providers = [:google, :twitter, :ldap]

Rails.application.config.omniauth_google = ENV['GOOGLE_OAUTH2_ID'].present?
Rails.application.config.omniauth_twitter = ENV['TWITTER_ID'].present?

#24042017 - Kristof VD Ouweland - Adding the LDAP provider and the boolean to verify if it is necessiary
Rails.application.config.omniauth_ldap = ENV['LDAP_ACTIVE'].present?


Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_ID'], ENV['TWITTER_SECRET']
  provider :google_oauth2, ENV['GOOGLE_OAUTH2_ID'], ENV['GOOGLE_OAUTH2_SECRET'],
    scope: ['profile', 'email'], access_type: 'online', name: 'google'

  #24042017 - Kristof VD Ouweland - Adding the LDAP provider and its connection. Perhaps better would be to set this via an environment varibale in the ENV file
  #Note: I cannot stress enough, try to use SSL or TLS connections for secure connections 
  provider :ldap,
 	:title => "LDAP Authenitication",
	:host => 'ldap server',
	:port => 389,
	:method => :plain,
	:base => ' base location ou=users,dc=domain,dc=com',
	:uid => 'uid',
	:name_proc => Proc.new {|name| name.gsub(/@.*$/,'')},
   	:bind_dn => 'bind user dn=admin,ou=users,dc=domain,dc=com',
	:password => 'bind user password'
end
