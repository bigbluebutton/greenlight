# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

MEETNG_OPTS = [
  # BBB options, for a full list check https://docs.bigbluebutton.org/dev/api.html#create:
  {
    name: 'record',
    value: 'false' # true|false
  },
  {
    name: 'muteOnStart',
    value: 'false' # true|false
  },
  {
    name: 'guestPolicy',
    value: 'ALWAYS_ACCEPT' # ALWAYS_ACCEPT | ALWAYS_DENY | ASK_MODERATOR
  },
  {
    name: 'attendeePW',
    value: ''
  },
  {
    name: 'moderatorPW',
    value: ''
  },
  # GL only options:
  {
    name: 'gl_anyone_can_start',
    value: 'false' # true | false
  },
  {
    name: 'gl_anyone_join_as_moderator',
    value: 'false' # true | false
  },
  {
    name: 'gl_moderator_access_code',
    value: ''
  },
  {
    name: 'gl_attendee_access_code',
    value: ''
  }
].freeze

# rubocop:disable Rails/SkipsModelValidations
MeetingOption.insert_all! MEETNG_OPTS
# rubocop:enable Rails/SkipsModelValidations
