FROM elixir:1.17.1-otp-27-alpine AS build

RUN apk add --no-cache build-base git

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
COPY config config/

RUN MIX_ENV=prod mix deps.get --only prod

COPY lib lib/
COPY priv priv/

RUN MIX_ENV=prod mix compile
RUN MIX_ENV=prod mix release

FROM alpine:3.18 AS app

RUN apk add --no-cache libstdc++ openssl ncurses-libs

WORKDIR /app

COPY --from=build /app/_build/prod/rel/seven_easy .
COPY --from=build /app/priv priv

ENV HOME=/app \
    MIX_ENV=prod \
    LANG=C.UTF-8

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]


