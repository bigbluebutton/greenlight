class AddUseHtml5ToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :use_html5, :boolean, default: false
  end
end
