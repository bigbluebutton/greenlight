class AddPasswordToRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :moderator_pw, :string, default: random_password(12)
    add_column :rooms, :attendee_pw, :string, default: random_password(12)
  end
end

# Generates a random password
def random_password(length)
  charset = ("a".."z").to_a + ("A".."Z").to_a
  ((0...length).map { charset[rand(charset.length)] }).join
end
