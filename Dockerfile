# syntax=docker/dockerfile:1
FROM ruby:3.4.7-slim
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client build-essential apt-utils libpq-dev libyaml-dev
WORKDIR /myapp
COPY . /myapp
RUN rm -rf /myapp/.gemset
RUN  bundle config set --local path '.gemset'
RUN  bundle install

# RUN git config --global core.symlinks false

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000 5444

# Configure the main process to run when running the image
CMD ["rails","db:migrate","&&","rails", "server", "-b", "0.0.0.0"]

