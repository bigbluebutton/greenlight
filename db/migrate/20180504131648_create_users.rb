class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.belongs_to :room, index: true
      t.string :provider
      t.string :uid
      t.string :name
      t.string :username
      t.string :email
      t.string :social_uid
      t.string :image
      t.string :password_digest, index: { unique: true }
      t.boolean :accepted_terms, default: false

      t.timestamps
    end
  end
end
