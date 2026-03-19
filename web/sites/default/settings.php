<?php

$databases['default']['default'] = [
  'driver'    => 'pgsql',
  'host'      => getenv('DRUPAL_DB_HOST') ?: 'db',
  'port'      => getenv('DRUPAL_DB_PORT') ?: '5432',
  'database'  => getenv('DRUPAL_DB_NAME'),
  'username'  => getenv('DRUPAL_DB_USER'),
  'password'  => getenv('DRUPAL_DB_PASSWORD'),
  'prefix'    => '',
  'namespace' => 'Drupal\\pgsql\\Driver\\Database\\pgsql',
  'autoload'  => 'core/modules/pgsql/src/Driver/Database/pgsql/',
];

$settings['hash_salt'] = getenv('DRUPAL_HASH_SALT');

$settings['trusted_host_patterns'] = [
  '^localhost$',
  '^127\.0\.0\.1$',
  '^brs-snpseek\.duckdns\.org$',
];

$settings['file_public_path']  = 'sites/default/files';
$settings['config_sync_directory'] = '../config/sync';

if (file_exists(__DIR__ . '/settings.local.php')) {
  include __DIR__ . '/settings.local.php';
}
