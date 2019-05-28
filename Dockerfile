FROM ruby:2.6.3-alpine

EXPOSE 3000
RUN apk add --update tzdata build-base sqlite sqlite-dev && mkdir app
COPY . app/
WORKDIR app
RUN bundle install

CMD ["rails", "s", "puma", "--binding", "0.0.0.0"]
