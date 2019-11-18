# frozen_string_literal: true

Role.create_default_roles("greenlight")
Rake::Task['admin:create'].invoke
