module ApplicationHelper
  def bbb_endpoint
    Rails.application.secrets[:bbb_endpoint]
  end

  def bbb_secret
    Rails.application.secrets[:bbb_secret]
  end

  def random_password(length)
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    password = (0...length).map { o[rand(o.length)] }.join
    return password
  end
end
