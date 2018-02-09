class AddResourceLinkIdToRailsLti2ProviderTool < ActiveRecord::Migration[5.0]
  def change
    add_column :rails_lti2_provider_tools, :resource_link_id, :string
    add_column :rails_lti2_provider_tools, :resource_type, :string
  end
end
