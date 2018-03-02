class UpdateToolProxySharedSecret < ActiveRecord::Migration
  def change
    change_column :rails_lti2_provider_tools, :shared_secret, :text, limit: nil
  end
end
