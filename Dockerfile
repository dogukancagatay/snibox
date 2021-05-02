FROM ruby:2.6.1-alpine3.9

WORKDIR /app

RUN apk add --no-cache \
    ruby-bundler \
    postgresql-dev \
    shared-mime-info \
    ca-certificates \
    libxml2 \
    libxslt \
    libressl \
    git \
    tzdata \
    nodejs \
    yarn

ENV NOKOGIRI_USE_SYSTEM_LIBRARIES=1
ENV RAILS_ENV production
ENV RACK_ENV production
ENV NODE_ENV production
ENV RAILS_SERVE_STATIC_FILES: "enabled"
ENV FORCE_SSL "false"
ENV DISABLE_AUTH "false"

# COPY Gemfile ./
COPY Gemfile Gemfile.lock ./

# && gem install bundler && \
RUN apk add --no-cache --virtual .build-dependencies \
    build-base \
    ruby-dev \
    libxml2-dev \
    libxslt-dev \
    libressl-dev && \
  bundle config --local build.nokogiri --use-system-libraries && \
  bundle config --local deployment true && \
  bundle config --local without "development test" && \
  bundle install && \
  gem cleanup && \
  apk del .build-dependencies && \
  rm -rf /usr/lib/ruby/gems/*/cache/* \
    /var/cache/apk/* \
    /tmp/* \
    /var/tmp/*

COPY . /app

RUN SECRET_KEY_BASE=docker ./bin/rake assets:precompile && \
  ./bin/yarn cache clean && \
  mkdir -p /static && \
  mv /app/entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]
EXPOSE 3000
VOLUME [ "/static" ]
CMD ["./bin/rails", "s", "-p", "3000", "-b", "0.0.0.0"]
