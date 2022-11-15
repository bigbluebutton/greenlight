# frozen_string_literal: true

class BackfillVerified < ActiveRecord::Migration[7.0]
  def up
    User.where.not(external_id: nil).update_all(verified: true) # rubocop:disable Rails/SkipsModelValidations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
