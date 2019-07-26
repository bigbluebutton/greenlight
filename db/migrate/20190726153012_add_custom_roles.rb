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
    add_index(:roles, [:name, :provider])

    # Look at all the old role assignments and and for each role create a new role
    # that is scoped to the provider
    old_assignments = ActiveRecord::Base.connection.execute("select * from users_roles")
    new_assignments = []

    old_assignments.each do |assignment|
      user = User.find(assignment["user_id"])
      new_assignment = { "role_id" => assignment["role_id"], "user_id" => assignment["user_id"] }
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
    new_role = ActiveRecord::Base.connection.execute("select * from roles where name = \'#{role_name}\'" \
      " and provider = \'#{provider}\'")

    if new_role.count.zero?
      if role_name == "user"
        ActiveRecord::Base.connection.execute("insert into roles (name, provider, can_create_rooms, colour, priority," \
          " created_at, updated_at) values (\'#{role_name}\',\'" \
          "#{provider}\', true, \'#868e96\', 1, " \
          "date(\'now\'), date(\'now\'))")
      elsif role_name == "admin"
        ActiveRecord::Base.connection.execute("insert into roles (name, provider, can_create_rooms, " \
          "send_promoted_email, send_demoted_email, can_edit_site_settings, can_edit_roles, can_manage_users, colour," \
          " priority, created_at, updated_at) values " \
          "(\'#{role_name}\',\'#{provider}\'," \
          " true, true, true, true, true, true, \'#f1c40f\', 0 ,date(\'now\'), date(\'now\'))")
      else
        ActiveRecord::Base.connection.execute("insert into roles (name, provider, priority, created_at, updated_at) " \
          "values (\'#{role_name}\',\'#{provider}" \
          "\', -1 , date(\'now\'), date(\'now\'))")
      end

      new_role = ActiveRecord::Base.connection.execute("select * from roles where name = \'#{role_name}\'" \
        " and provider = \'#{provider}\'")
    end

    new_role.first["id"]
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
