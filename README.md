# 1001 Philippine Rice Genome Portal

A Tripal-powered bioinformatics portal for the 1001 Philippine Rice Genome initiative — cataloguing the genetic diversity of Philippine rice varieties to support breeding, conservation, and food security research.

**Live URL:** https://brs-snpseek.duckdns.org/ph_gdb/  
**Built with:** Drupal 10 + Tripal + PostgreSQL + Docker  
**Maintained by:** IRRI Bioinformatics Unit  
**Partners:** University of the Philippines System, DA-PhilRice, UPLB

---

## Table of Contents

- [Stack](#stack)
- [Repo Structure](#repo-structure)
- [Local Development Setup](#local-development-setup)
- [First-Time Production Install](#first-time-production-install)
- [CI/CD Pipeline](#cicd-pipeline)
- [Theme](#theme)
- [Portal Pages](#portal-pages)
- [Persisting Pages and Config](#persisting-pages-and-config)
- [Reusing This Project](#reusing-this-project)
- [Environment Variables](#environment-variables)

---

## Stack

| Layer | Technology |
|---|---|
| CMS | Drupal 10 |
| Bioinformatics framework | Tripal 4 |
| Database | PostgreSQL 15 |
| Web server | Apache (inside Docker) |
| Reverse proxy | Nginx (server-level) |
| Containerisation | Docker + Docker Compose |
| CI/CD | GitHub Actions + self-hosted runner |
| OS (prod) | Amazon Linux 2023 |

---

## Repo Structure

```
PH_GDB_Portal/
├── .github/
│   └── workflows/
│       ├── ci.yml              # Build check on every PR
│       └── cd.yml              # Auto-deploy on push to main
├── config/
│   └── sync/                   # Drupal exported config (persisted in repo)
├── scripts/
│   └── create-pages.sh         # Creates all portal pages via Drush
├── web/
│   ├── sites/
│   │   └── default/
│   │       └── settings.php    # Drupal DB + trusted host config
│   └── themes/
│       └── custom/
│           └── phrice/         # Custom UP-branded Drupal theme
│               ├── css/
│               │   └── style.css
│               ├── js/
│               │   └── main.js
│               ├── templates/
│               │   ├── page.html.twig
│               │   └── node--landing-page.html.twig
│               ├── phrice.info.yml
│               └── phrice.libraries.yml
├── .env.example                # Environment variable template
├── .gitignore
├── Dockerfile                  # Drupal + Tripal + Apache image
├── docker-compose.yml          # Web + DB services
└── README.md
```

---

## Local Development Setup

### Prerequisites

- Windows with WSL2 (Ubuntu)
- Docker Desktop with WSL2 backend enabled
- Git
- VS Code with Remote - WSL extension

### Steps

**1. Clone the repo inside WSL (not /mnt/c/):**
```bash
mkdir -p ~/projects
cd ~/projects
git clone git@github.com:IRRI-Bioinformatics-Official/PH_GDB_Portal.git
cd PH_GDB_Portal
```

**2. Set up environment variables:**
```bash
cp .env.example .env
nano .env   # fill in your values
```

**3. Fix line endings (important on Windows):**
```bash
sudo apt-get install -y dos2unix
dos2unix .env
```

**4. Build and start containers:**
```bash
docker compose up -d --build
```

**5. Install Drupal:**
```bash
set -a && source .env && set +a

docker compose exec web /opt/drupal/vendor/bin/drush site:install standard \
  --db-url="pgsql://${TripalDB_USER}:${TripalDB_PASSWORD}@db:5432/${TripalDB_NAME}" \
  --site-name="1001 Philippine Rice Genome Portal" \
  --account-name=admin \
  --account-pass=changeme \
  --yes
```

**6. Create all portal pages:**
```bash
bash scripts/create-pages.sh
```

This script creates the landing page, Genotype Viewer, JBrowse, and JBrowse2 pages automatically. It is idempotent — safe to run multiple times.

**7. Access the portal:**  
Open http://localhost:8085

---

## First-Time Production Install

SSH into the production server, then:

```bash
# Clone the repo
git clone git@github.com:IRRI-Bioinformatics-Official/PH_GDB_Portal.git /opt/PH_GDB_Portal
cd /opt/PH_GDB_Portal

# Set up environment
cp .env.example .env
nano .env   # fill in production credentials

# Start containers
docker compose up -d --build

# Wait for DB, then install Drupal
sleep 15
set -a && source .env && set +a

docker compose exec -T web /opt/drupal/vendor/bin/drush site:install standard \
  --db-url="pgsql://${TripalDB_USER}:${TripalDB_PASSWORD}@db:5432/${TripalDB_NAME}" \
  --site-name="1001 Philippine Rice Genome Portal" \
  --account-name=admin \
  --account-pass=changeme_immediately \
  --yes

# Enable modules and theme + create all pages
bash scripts/create-pages.sh

# Change admin password immediately
docker compose exec -T web /opt/drupal/vendor/bin/drush user:password admin 'your-secure-password'
```

---

## CI/CD Pipeline

| Workflow | Trigger | Runner | What it does |
|---|---|---|---|
| `ci.yml` | Pull request to `main` | GitHub-hosted (`ubuntu-latest`) | Builds Docker image, starts containers, verifies health |
| `cd.yml` | Push to `main` | Self-hosted (`BRS_tripal` runner on prod server) | Syncs latest code via `git reset --hard`, rebuilds containers, runs Drush updates, runs `create-pages.sh`, rebuilds cache |

> The CD workflow uses `git reset --hard origin/main` to avoid divergent branch conflicts — the server workspace always matches `main` exactly.

### Setting up the self-hosted runner

On the production server:
```bash
mkdir -p ~/tripal-runner && cd ~/tripal-runner

curl -o actions-runner-linux-x64.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.314.1/actions-runner-linux-x64-2.314.1.tar.gz
tar xzf actions-runner-linux-x64.tar.gz

./config.sh \
  --url https://github.com/IRRI-Bioinformatics-Official/PH_GDB_Portal \
  --token YOUR_TOKEN \
  --name BRS_tripal \
  --unattended

sudo ./svc.sh install
sudo ./svc.sh start
```

### Docker Buildx requirement

Docker Buildx v0.17.1+ is required on the production server:
```bash
mkdir -p ~/.docker/cli-plugins
curl -SL https://github.com/docker/buildx/releases/download/v0.17.1/buildx-v0.17.1.linux-amd64 \
  -o ~/.docker/cli-plugins/docker-buildx
chmod +x ~/.docker/cli-plugins/docker-buildx
docker buildx install
```

---

## Theme

The custom theme is located at `web/themes/custom/phrice/`.

It uses **UP (University of the Philippines) branding** — maroon, gold, and green color palette — with IRRI and DA-PhilRice acknowledged in the footer. The stats strip uses Option A: dark to light maroon shades with a gold end cap.

| File | Purpose |
|---|---|
| `phrice.info.yml` | Theme metadata and region definitions |
| `phrice.libraries.yml` | CSS and JS asset registration |
| `css/style.css` | All theme styles including nav dropdown |
| `js/main.js` | Genome grid animation |
| `templates/page.html.twig` | Main page layout — nav with Data dropdown, footer |
| `templates/node--landing-page.html.twig` | Landing page sections (hero, stats, about, news) |

To update the landing page content after template changes:
```bash
docker compose exec -T web /opt/drupal/vendor/bin/drush php:eval "
\$node = \Drupal\node\Entity\Node::load(1);
\$node->set('body', [
  'value' => file_get_contents('/opt/drupal/web/themes/custom/phrice/templates/node--landing-page.html.twig'),
  'format' => 'full_html',
]);
\$node->save();
"
docker compose exec -T web /opt/drupal/vendor/bin/drush cache:rebuild
```

---

## Portal Pages

| Page | URL | Description |
|---|---|---|
| Landing page | `/ph_gdb/` | Hero, stats, about, news sections |
| Genotype Viewer | `/ph_gdb/data/genotype-viewer` | Embedded SNP-Seek genotype search microservice |
| JBrowse | `/ph_gdb/data/jbrowse` | JBrowse 1 genome browser (rice reference + MSU7 tracks) |
| JBrowse2 | `/ph_gdb/data/jbrowse2` | JBrowse 2 next-generation genome browser |

### Embedded tools

| Tool | Source URL |
|---|---|
| Genotype Viewer | `http://snpseekv3.duckdns.org/1k1/1k1_prototype.zul` |
| JBrowse | `https://brs-snpseek.duckdns.org/jbrowse/?loc=chr01:2902..10816&tracks=DNA,msu7gff` |
| JBrowse2 | `https://brs-snpseek.duckdns.org/jbrowse2/?session=local-Okuh4ZhqgE-BsamEZOmCK` |

> Note: The Genotype Viewer uses `http://` — if the portal is on `https://` the browser may block the iframe due to mixed content. Configure Nginx to proxy it if needed.

### Admin access

```
https://brs-snpseek.duckdns.org/ph_gdb/user/login
```
Username: `admin` — reset password via:
```bash
docker compose exec -T web /opt/drupal/vendor/bin/drush user:password admin 'your-new-password'
```

---

## Persisting Pages and Config

Portal pages are created in the Drupal database and would be lost on a fresh install. Two mechanisms keep them safe:

### 1. `scripts/create-pages.sh`
A Drush script that recreates all pages idempotently (checks before creating). It is called automatically by the CD workflow on every deploy and can be run manually:
```bash
bash scripts/create-pages.sh
```

### 2. `config/sync/`
Drupal configuration exported to the repo. This persists theme settings, content type config, URL aliases, and module settings. To re-export after making config changes in the UI:
```bash
docker compose exec -T web /opt/drupal/vendor/bin/drush config:export --yes
docker cp 1k1_portal_web:/opt/drupal/config/sync/. config/sync/
git add config/
git commit -m "chore: export updated Drupal config"
git push origin main
```

---

## Reusing This Project

This repo is structured to be reusable for other Tripal-based genomics portals. To adapt it for a new project:

**1. Fork or clone the repo:**
```bash
git clone git@github.com:IRRI-Bioinformatics-Official/PH_GDB_Portal.git my_new_portal
cd my_new_portal
git remote set-url origin git@github.com:YOUR_ORG/my_new_portal.git
```

**2. Update environment variables** in `.env.example`:
- Change `TripalDB_NAME`, `TripalDB_USER`, `TripalDB_PASSWORD`
- Update `DRUPAL_HASH_SALT` with a new random string: `openssl rand -base64 48`

**3. Update the theme** in `web/themes/custom/phrice/`:
- Edit `css/style.css` — change CSS variables in `:root {}` for new colors
- Edit `templates/node--landing-page.html.twig` — update hero text, stats, about content, news items
- Edit `templates/page.html.twig` — update site name, nav links, footer text

**4. Update `settings.php`** trusted host patterns:
```php
$settings['trusted_host_patterns'] = [
  '^localhost$',
  '^your-new-domain\.org$',
];
$settings['base_url'] = 'https://your-new-domain.org/your-subpath';
```

**5. Update GitHub Actions workflows** in `.github/workflows/`:
- In `cd.yml`, update `runs-on` labels to match your new server's runner
- Update the `.env` copy path if different from `/home/ec2-user/.env.phgdb`

**6. Register a new self-hosted runner** on your new production server (see CI/CD section above).

**7. Push and deploy:**
```bash
git add .
git commit -m "init: configure for new portal"
git push origin main
```

---

## Environment Variables

| Variable | Description | Example |
|---|---|---|
| `TripalDB_NAME` | PostgreSQL database name | `phgdb_portal` |
| `TripalDB_USER` | PostgreSQL username | `phgdb_user` |
| `TripalDB_PASSWORD` | PostgreSQL password | `strongpassword` |
| `TripalDB_HOST` | DB host (use `db` inside Docker) | `db` |
| `TripalDB_PORT` | DB port | `5432` |
| `DRUPAL_HASH_SALT` | Drupal security salt (random 64-char string) | `openssl rand -base64 48` |
| `DRUPAL_SITE_NAME` | Site display name | `1001 Philippine Rice Genome Portal` |

> **Never commit `.env` to version control.** Only commit `.env.example` with placeholder values.

---

## Notes

- **Reverse Proxy Support:** The portal runs on port `8085` internally, proxied by the server's existing Nginx at `/ph_gdb/`. To ensure correct URL generation and login functionality, the Nginx location block must pass the correct headers:
  ```nginx
  location /ph_gdb/ {
      proxy_pass http://localhost:8085/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Prefix /ph_gdb;
  }
  ```
- **Login Issues:** If login redirects fail, ensure `X-Forwarded-Prefix` is set correctly in Nginx as shown above. The `settings.php` has been updated to trust these headers.
- **Cache:** Drupal cache must be rebuilt after any theme or config changes: `drush cache:rebuild`
- The self-hosted runner `.env` file is stored at `/home/ec2-user/.env.phgdb` on the production server and copied by the CD workflow at deploy time
- Docker Buildx v0.17.1+ is required on the production server
- WSL users: always work inside the Linux filesystem (`~/projects/`) not `/mnt/c/` — Docker volumes and file permissions behave incorrectly on the Windows filesystem
- If pushing to GitHub fails from WSL on a corporate network, push directly from the production server which has unrestricted internet access
- The `sub_filter` directives in Nginx rewrite asset paths for the `/ph_gdb/` subdirectory — avoid using `clip-path` in CSS as it may be rewritten incorrectly