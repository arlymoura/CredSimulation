# Dockerfile

FROM ruby:3.2.0

RUN apt-get update -qq && apt-get install -y \
  curl \
  gnupg2 \
  build-essential \
  libpq-dev \
  nodejs \
  postgresql-client \
  git


WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install

COPY . /app

EXPOSE 3000

# CMD ["bin/dev"]
CMD ["rails", "server", "-b", "0.0.0.0"]
