class AddStreamingKeyToStreaming < ActiveRecord::Migration[5.2]
  def change
    add_column :streamings, :streaming_key, :string
  end
end
