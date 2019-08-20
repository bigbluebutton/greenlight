# frozen_string_literal: true

class AddCustomRoles < ActiveRecord::Migration[5.2]
  def up
    super_admin_id = -1
    user_id = -1
    admin_id = -1
    denied_id = -1
    pending_id = -1

    old_roles = ActiveRecord::Base.connection.execute("select * from roles")

    # Determine what ids corresponded to what roles in the old table
    old_roles.each do |role|
      if role["name"] == "super_admin"
        super_admin_id = role["id"]
      elsif role["name"] == "user"
        user_id = role["id"]
      elsif role["name"] == "admin"
        admin_id = role["id"]
      elsif role["name"] == "denied"
        denied_id = role["id"]
      elsif role["name"] == "pending"
        pending_id = role["id"]
      end
    end

    # Replace Rolify's table with our own
    drop_table :roles

    create_table(:roles) do |t|
      t.string :name
      t.integer :priority, default: 9999
      t.boolean :can_create_rooms, default: false
      t.boolean :send_promoted_email, default: false
      t.boolean :send_demoted_email, default: false
      t.boolean :can_edit_site_settings, default: false
      t.boolean :can_edit_roles, default: false
      t.boolean :can_manage_users, default: false
      t.string  :colour
      t.string :provider

      t.timestamps
    end

    add_index(:roles, :name)
    add_index(:roles, [:name, :provider], unique: true)

    # Look at all the old role assignments and and for each role create a new role
    # that is scoped to the provider
    old_assignments = ActiveRecord::Base.connection.execute("select * from users_roles")
    new_assignments = []

    old_assignments.each do |assignment|
      begin
        user = User.find(assignment["user_id"])
      rescue
        next
      end

      new_assignment = { "user_id" => assignment["user_id"] }
      if assignment["role_id"] == super_admin_id
        new_assignment["new_role_id"] = generate_scoped_role(user, "super_admin")
      elsif assignment["role_id"] == user_id
        new_assignment["new_role_id"] = generate_scoped_role(user, "user")
      elsif assignment["role_id"] == admin_id
        new_assignment["new_role_id"] = generate_scoped_role(user, "admin")
      elsif assignment["role_id"] == denied_id
        new_assignment["new_role_id"] = generate_scoped_role(user, "denied")
      elsif assignment["role_id"] == pending_id
        new_assignment["new_role_id"] = generate_scoped_role(user, "pending")
      end

      new_assignments << new_assignment
    end

    assign_new_users(new_assignments)
  end

  def generate_scoped_role(user, role_name)
    provider = Rails.configuration.loadbalanced_configuration ? user.provider : 'greenlight'
    new_role = Role.find_by(name: role_name, provider: provider)

    if new_role.nil?
      Role.create_default_roles(provider)

      new_role = Role.find_by(name: role_name, provider: provider)
    end

    new_role.id
  end

  def assign_new_users(new_assignments)
    # Delete the old assignments
    ActiveRecord::Base.connection.execute("DELETE FROM users_roles")
    # Add the role assignments to the new roles
    new_assignments.each do |assignment|
      if assignment['new_role_id']
        ActiveRecord::Base.connection.execute("INSERT INTO users_roles (user_id, role_id)" \
          " VALUES (#{assignment['user_id']}, #{assignment['new_role_id']})")
      end
    end
  end

  def down
    drop_table :roles

    create_table(:roles) do |t|
      t.string :name
      t.references :resource, polymorphic: true

      t.timestamps
    end
  end
end
