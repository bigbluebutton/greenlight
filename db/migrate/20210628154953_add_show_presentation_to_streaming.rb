class AddShowPresentationToStreaming < ActiveRecord::Migration[5.2]
  def change
    add_column :streamings, :show_presentation, :string
  end
end
