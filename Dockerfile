FROM jmervine/herokudev-ruby:2.3.1

# need it for debugging delayed_job
RUN apt-get update -y && apt-get install postgresql-client -y
RUN gem install foreman --no-document

