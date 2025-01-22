FROM ruby:2.7.8

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

RUN rails db:prepare

CMD ["rails", "server", "-b", "0.0.0.0"]