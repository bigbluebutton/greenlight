module ApplicationHelper
  def bbb_endpoint
    logger.info APP_CONFIG
    #if ((defined? APP_CONFIG).to_s == 'constant') && (APP_CONFIG.has_key?('bbb_endpoint'))
    #  APP_CONFIG['bbb_endpoint']
    #else
      'http://test-install.blindsidenetworks.com/bigbluebutton/'
    #end
  end

  def bbb_secret
    #if (defined? APP_CONFIG).to_s == 'constant' && (APP_CONFIG.has_key? 'bbb_secret')
    #  APP_CONFIG['bbb_secret']
    #else
      '8cd8ef52e8e101574e400365b55e11a6'
    #end
  end

  def random_password(length)
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    password = (0...length).map { o[rand(o.length)] }.join
    return password
  end
end
