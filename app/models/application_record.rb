class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
  def to_param
    uid  
  end
end
