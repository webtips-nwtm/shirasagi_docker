FROM --platform=amd64 node:20.9.0 as node
FROM --platform=amd64 ruby:3.0.4

#　nodeイメージからyarn,nodeをコピーする
COPY --from=node /opt/yarn-* /opt/yarn
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules/ /usr/local/lib/node_modules/

RUN ln -fs /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -fs /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npx \
    && ln -fs /usr/local/lib/node /usr/local/bin/nodejs \
    && ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarn \
    && ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarnpkg


ENV LANG C.UTF-8
#RUN apt-get update -qq && apt-get install -y gcc make libssl-dev zlib1g-dev build-essential libpq-dev \

WORKDIR /shirasagi
COPY shirasagi/Gemfile Gemfile
COPY shirasagi/Gemfile.lock Gemfile.lock
COPY shirasagi/vendor/bundle shirasagi/vendor/bundle
RUN bundle config set --local path vendor/bundle
RUN bundle install --path vendor/bundle

#COPY entrypoint.sh /usr/bin/
#RUN chmod +x /usr/bin/entrypoint.sh
#ENTRYPOINT ["entrypoint.sh"]
