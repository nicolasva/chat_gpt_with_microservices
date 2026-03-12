FROM ruby:3.4.4-alpine

WORKDIR /app

RUN apk add --no-cache build-base

COPY Gemfile Gemfile.lock* ./
RUN bundle install --without development test

COPY . .

RUN mkdir -p tmp

EXPOSE 3002

CMD ["bundle", "exec", "ruby", "app.rb"]
