# frozen_string_literal: true

FactoryBot.define do
  factory :avatar do
    supporting_documentation_file_name { 'test.pdf' }
    supporting_documentation_content_type { 'application/pdf' }
    supporting_documentation_file_size { 1024 }
  end
end
