# frozen_string_literal: true

class FixAccessToVisibilitiesValue < ActiveRecord::Migration[7.1]
  def up
    # rubocop:disable Rails/SkipsModelValidations
    Permission.find_by(name: 'AccessToVisibilities').role_permissions.where(value: 'false').update_all(value: Recording::VISIBILITIES.values)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
