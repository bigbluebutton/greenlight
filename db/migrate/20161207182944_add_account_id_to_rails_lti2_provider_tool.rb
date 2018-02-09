class AddAccountIdToRailsLti2ProviderTool < ActiveRecord::Migration
  def change
    add_column :rails_lti2_provider_tools, :account_id, :integer
  end
end
