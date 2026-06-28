FROM php:8.4-cli

RUN apt-get update && apt-get install -y --no-install-recommends \
      git unzip curl ca-certificates libzip-dev libpng-dev libonig-dev \
 && docker-php-ext-install pdo pdo_mysql mbstring bcmath zip gd \
 && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction \
 && npm ci && npm run build \
 && rm -rf node_modules

COPY docker-entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint \
 && chmod -R 775 storage bootstrap/cache

ENV APP_ENV=production
EXPOSE 8080
CMD ["entrypoint"]
