FROM ruby:3.2.2-slim

RUN apt-get update -qq && apt-get install -y build-essential

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 3000

# Comando para iniciar la aplicación
CMD ["bundle", "exec", "rackup", "-p", "3000", "-o", "0.0.0.0"]