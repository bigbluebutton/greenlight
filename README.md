# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

Install Ruby 3.1.0

* System dependencies

```
bundle install
```

* Configuration

Initialize environment variables (DATABASE_URL, BIGBLUEBUTTON_SECRET and BIGBLUEBUTTON_ENDPOINT, PORT is optional)

```
cp dotenv .env
```


* Database creation

```
rake db:create
rake db:migrate:with_data
```

* Database initialization

```
rake db:seed
```

* How to run the test suite

```
./bin/start
```

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


Install Ruby 3.1.0

bundle install
cp dotenv .env

Set DATABASE_URL, BIGBLUEBUTTON_SECRET and BIGBLUEBUTTON_ENDPOINT

rake db:create
rake db:migrate:with_data

./bin/start


For production

RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true

rake assets:precompile
