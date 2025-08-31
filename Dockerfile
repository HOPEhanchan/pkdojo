# ==== Base (共通) ====
ARG RUBY_VERSION=3.3.9
FROM registry.docker.com/library/ruby:${RUBY_VERSION}-slim AS base

# 共通の環境変数（bundleのパスなど）
ENV BUNDLE_PATH="/usr/local/bundle" \
    GEM_HOME="/usr/local/bundle" \
    BUNDLE_BIN="/usr/local/bundle/bin" \
    PATH="/usr/local/bundle/bin:${PATH}"

WORKDIR /rails

# ==== Development ターゲット ====
# ローカル開発用: dev/gems も入れる（foreman 等）
FROM base AS dev
ENV RAILS_ENV="development" \
    BUNDLE_WITHOUT=""

# ネイティブ拡張のビルド & JS 実行に必要なもの
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      libyaml-dev\
      libvips \
      pkg-config \
      nodejs \
      postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# 先に Gemfile だけコピーして bundle キャッシュを効かせる
COPY Gemfile* ./
RUN bundle install

# アプリ全体
COPY . .

# dev用: ポート開ける & デフォルトCMD（foremanで起動）
EXPOSE 3000
CMD ["bin/dev"]


# ==== Production ビルドステージ ====
FROM base AS build
# 本番ビルドでは dev/test を除外（イメージを軽く）
ENV RAILS_ENV="production" \
    BUNDLE_WITHOUT="development:test"

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      libyaml-dev\
      libvips \
      pkg-config && \
    rm -rf /var/lib/apt/lists/*

# gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# アプリ全体
COPY . .

# bootsnap & assets（RAILS_MASTER_KEY不要のダミー鍵でプリコンパイル）
RUN bundle exec bootsnap precompile app/ lib/ && \
    SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


# ==== Production 最終ステージ ====
FROM base AS final
ENV RAILS_ENV="production" \
    BUNDLE_WITHOUT="development:test"

# 走行時に必要なものだけ
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libvips \
      postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# bundle とアプリをコピー
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# セキュリティ: 非rootで実行
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 3000
CMD ["./bin/rails", "server"]
