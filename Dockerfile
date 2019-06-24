FROM ruby:2.6.2
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN mkdir /iot_thermostats

WORKDIR /iot_thermostats

ARG RAILS_ENV
ARG DATABASE_URL


COPY Gemfile /iot_thermostats/Gemfile
COPY Gemfile.lock /iot_thermostats/Gemfile.lock
RUN bundle install
COPY . /iot_thermostats

# Add a script to be executed every time the container starts.
VOLUME ["/app/public"]

RUN chmod -v +x /iot_thermostats/scripts/* \
    && mv -v /iot_thermostats/scripts/docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
