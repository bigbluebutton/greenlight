class AddOriginToRailsLti2ProviderTools < ActiveRecord::Migration[5.0]
  def change
    add_column :rails_lti2_provider_tools, :origin, :string
  end
end
