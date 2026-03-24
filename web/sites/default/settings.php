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

/**
 * Reverse proxy settings.
 * Required for correct URL generation behind Nginx.
 */
$settings['reverse_proxy'] = TRUE;
// In Docker environments, the proxy is often the gateway or a known internal IP.
// Using $_SERVER['REMOTE_ADDR'] as a trusted proxy is common in these setups.
$settings['reverse_proxy_addresses'] = [$_SERVER['REMOTE_ADDR']];

// Handle HTTPS termination at the proxy.
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
  $_SERVER['HTTPS'] = 'on';
}

// Handle subdirectory if the proxy strips the prefix (X-Forwarded-Prefix).
// This ensures Drupal knows it is served from /ph_gdb.
$prefix = getenv('DRUPAL_BASE_PATH') ?: (isset($_SERVER['HTTP_X_FORWARDED_PREFIX']) ? $_SERVER['HTTP_X_FORWARDED_PREFIX'] : '/ph_gdb');
if ($prefix) {
  $prefix = '/' . ltrim($prefix, '/');
  // Force the base path in Symfony Request.
  $_SERVER['SCRIPT_NAME'] = $prefix . $_SERVER['SCRIPT_NAME'];
  $_SERVER['REQUEST_URI'] = $prefix . $_SERVER['REQUEST_URI'];
}

$settings['file_public_path']  = 'sites/default/files';
$settings['config_sync_directory'] = '../config/sync';

if (file_exists(__DIR__ . '/settings.local.php')) {
  include __DIR__ . '/settings.local.php';
}
