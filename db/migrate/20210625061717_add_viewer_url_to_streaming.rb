class AddViewerUrlToStreaming < ActiveRecord::Migration[5.2]
  def change
    add_column :streamings, :viewer_url, :string
  end
end
