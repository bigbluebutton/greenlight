class AddVersionAndRenameToolProxyModel < ActiveRecord::Migration
  def change
    rename_table :rails_lti2_provider_tool_proxies, :rails_lti2_provider_tools
    add_column :rails_lti2_provider_tools, :lti_version, :string
    rename_column :rails_lti2_provider_tools, :proxy_json, :tool_settings
    rename_column :rails_lti2_provider_registrations, :tool_proxy_id, :tool_id
    rename_column :rails_lti2_provider_lti_launches, :tool_proxy_id, :tool_id

    reversible do |dir|
      dir.up do
        #set lti_version to LTI-2p0
        execute <<-SQL
        UPDATE rails_lti2_provider_tools SET lti_version = 'LTI-2p0';
        SQL
      end

      dir.down do
        #lti_version will get dropped so no need to do anything
      end
    end

  end
end
