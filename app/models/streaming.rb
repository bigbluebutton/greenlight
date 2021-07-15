class Streaming < ApplicationRecord
    validates :url, presence: false
    validates :meeting_id, presence: false
    validates :viewer_url, presence: false
    validates :streaming_key, presence: false
    validates :show_presentation, presence: false
end
