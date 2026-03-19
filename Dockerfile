# ============================================================
# 1k1_portal — Drupal + Tripal on Apache + PHP
# ============================================================

FROM drupal:10-apache

# ── System dependencies ──────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    curl \
    libpq-dev \
    postgresql-client \
    && docker-php-ext-install pdo pdo_pgsql pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ── Composer (global) ────────────────────────────────────────
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ── Drush launcher ───────────────────────────────────────────
RUN curl -fsSL https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar \
    -o /usr/local/bin/drush \
    && chmod +x /usr/local/bin/drush

# ── Working directory (Drupal is pre-installed at /opt/drupal) ─
WORKDIR /opt/drupal

# ── Install Tripal via Composer ───────────────────────────────
RUN composer config minimum-stability dev \
    && composer config prefer-stable true \
    && composer require drush/drush --no-interaction --prefer-dist \
    && composer require tripal/tripal:^4.x-dev --no-interaction --prefer-dist    
# ── File permissions ──────────────────────────────────────────
RUN mkdir -p /opt/drupal/web/sites/default/files \
    && chown -R www-data:www-data /opt/drupal/web/sites \
    && chmod -R 775 /opt/drupal/web/sites/default/files

# ── Apache: enable mod_rewrite ────────────────────────────────
RUN a2enmod rewrite

EXPOSE 80