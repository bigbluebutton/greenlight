# frozen_string_literal: true

class AddRegionToTenants < ActiveRecord::Migration[7.2]
  def change
    add_column :tenants, :region, :string
  end
end
