class UpdateToolIdType < ActiveRecord::Migration
  def change
    if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) &&
        ActiveRecord::Base.connection.instance_of?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
      change_column :rails_lti2_provider_lti_launches, :tool_id, "bigint USING CAST(tool_id AS bigint)"
      change_column :rails_lti2_provider_registrations, :tool_id, "bigint USING CAST(tool_id AS bigint)"
    else
      change_column :rails_lti2_provider_lti_launches, :tool_id, :integer, limit: 8
      change_column :rails_lti2_provider_registrations, :tool_id, :integer, limit: 8
    end
  end
end
