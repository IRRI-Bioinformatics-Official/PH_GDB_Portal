# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The **1001 Philippine Rice Genome Portal** is a Drupal 10 + Tripal 4 bioinformatics portal cataloguing genetic diversity of Philippine rice varieties. It runs inside Docker, deployed at `https://brs-snpseek.duckdns.org/ph_gdb/` via an Nginx reverse proxy.

## Common Commands

All operations run via `drush` inside the `web` container (`1k1_portal_web`).

```bash
# Start/rebuild containers
docker compose up -d --build

# Run Drush commands
docker compose exec web /opt/drupal/vendor/bin/drush <command>

# Rebuild Drupal cache
docker compose exec web /opt/drupal/vendor/bin/drush cache:rebuild

# Export current Drupal config to git
docker compose exec -T web /opt/drupal/vendor/bin/drush config:export --yes
docker cp 1k1_portal_web:/opt/drupal/config/sync/. config/sync/

# Import config from git
docker compose exec web /opt/drupal/vendor/bin/drush config:import --yes

# Create/refresh all portal pages (idempotent, safe to re-run)
bash scripts/create-pages.sh

# Reset admin password
docker compose exec web /opt/drupal/vendor/bin/drush user:password admin "newpassword"
```

## Architecture

**Stack:** Drupal 10 + Tripal 4 → PostgreSQL 15, served via Apache inside Docker, reverse-proxied by Nginx at `/ph_gdb/`.

**Key design decisions:**

- **Subdirectory prefix is hardcoded** as `/ph_gdb` in theme settings and `settings.php`. Drupal reads the `X-Forwarded-Prefix` header from Nginx to generate correct URLs. Do not remove this or Drupal login and URL generation will break.

- **Config as code:** All Drupal configuration lives in `config/sync/` (version-controlled). Changes made in the Drupal admin UI must be exported with `drush config:export` and committed. On deploy, `drush config:import` reapplies them.

- **Page content is script-managed:** The four portal pages (Landing, Genotype Viewer, JBrowse, JBrowse2) are created/updated by `scripts/create-pages.sh` using Drush. This is the canonical way to change page content — not the Drupal UI — because the CD pipeline re-runs this script on every deploy.

- **Theme mounts as a live volume:** `./web/themes` is bind-mounted into the container, so CSS/JS/Twig changes are reflected without rebuilding the image. A cache rebuild (`drush cr`) is still needed for Twig and theme changes.

- **External tools via iframes:** Genotype Viewer (SNP-Seek), JBrowse, and JBrowse2 are embedded as iframes. Their URLs are hardcoded in `scripts/create-pages.sh`. The Genotype Viewer must use HTTPS to avoid mixed-content blocking from the HTTPS portal.

## Theme: `phrice`

Located at `web/themes/custom/phrice/`. UP-branded (maroon `#7b1113`, gold `#c9961a`, green `#2d6a3f`). Key files:

- `css/style.css` — All styles; colors defined as CSS variables in `:root {}`
- `js/main.js` — Genome grid animation (random cell state changes every 300ms)
- `templates/page.html.twig` — Site-wide layout: nav, Data dropdown, footer
- `templates/node--landing-page.html.twig` — Landing page sections (hero, stats, about, news)

## Environment Variables

Copy `.env.example` to `.env` before starting. Required variables:

| Variable | Purpose |
|---|---|
| `TripalDB_NAME` | PostgreSQL database name |
| `TripalDB_USER` | PostgreSQL username |
| `TripalDB_PASSWORD` | PostgreSQL password |
| `DRUPAL_HASH_SALT` | Drupal security token (64-char random string) |
| `DRUPAL_BASE_PATH` | Optional override for subdirectory (defaults to auto-detect from `X-Forwarded-Prefix`) |

## CI/CD

- **CI (`ci.yml`):** Runs on every PR to `main`. Builds Docker, starts services, verifies HTTP health. Uses GitHub-hosted runner.
- **CD (`cd.yml`):** Runs on push to `main`. Uses a self-hosted runner on the production EC2 instance (`BRS_tripal`). Does `git reset --hard origin/main` (not a normal pull), rebuilds containers, runs Drush updates, re-runs `create-pages.sh`, and rebuilds cache.

Production `.env` is stored at `/home/ec2-user/.env.phgdb` on the server and copied during deploy — it is never in git.

## Local Development Notes

- Must develop inside the Linux filesystem (e.g., `~/projects/`), **not** `/mnt/c/` — Docker volume bind mounts fail on the Windows filesystem with WSL2.
- Run `dos2unix .env` after creating it on Windows to fix line endings.
- Drupal is accessible at `http://localhost:8085` locally (no `/ph_gdb/` prefix when accessing directly).
