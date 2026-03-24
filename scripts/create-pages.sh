#!/bin/bash
# ============================================================
# 1k1_portal — create-pages.sh
# Creates all portal pages in Drupal via Drush.
# Run this after site:install on a fresh instance.
# Usage: bash scripts/create-pages.sh
# ============================================================

set -euo pipefail

DRUSH="/opt/drupal/vendor/bin/drush"

echo "==> Creating portal pages..."

docker compose exec -T web $DRUSH php:eval "

// ── Landing page ─────────────────────────────────────────────
\$node = \Drupal\node\Entity\Node::load(1);
if (!\$node) {
  \$node = \Drupal\node\Entity\Node::create([
    'type' => 'page',
    'title' => 'Welcome to the 1001 Philippine Rice Genome Portal',
  ]);
  echo 'Creating Landing page...' . PHP_EOL;
} else {
  echo 'Updating existing Landing page...' . PHP_EOL;
}

\$node->set('body', [
  'value' => file_get_contents('/opt/drupal/web/themes/custom/phrice/templates/node--landing-page.html.twig'),
  'format' => 'full_html',
]);
\$node->status = 1;
\$node->save();

\Drupal::configFactory()->getEditable('system.site')->set('page.front', '/node/' . \$node->id())->save();

// ── Genotype Viewer ───────────────────────────────────────────
\$gv_nodes = \Drupal::entityTypeManager()->getStorage('node')->loadByProperties(['title' => 'Genotype Viewer']);
\$n = !empty(\$gv_nodes) ? reset(\$gv_nodes) : \Drupal\node\Entity\Node::create(['type' => 'page', 'title' => 'Genotype Viewer']);

echo (empty(\$gv_nodes) ? 'Creating' : 'Updating') . ' Genotype Viewer...' . PHP_EOL;
\$n->set('body', [
  'value' => '<div class=\"page-hero\"><div class=\"page-hero-inner\"><div class=\"page-hero-tag\"><span>Data — Genotype Viewer</span></div><h1>Genotype Viewer</h1><p>Explore and compare genotypic data across 1,001 Philippine rice accessions. Filter by chromosome, position, or accession to visualise SNP variants across the collection.</p></div></div><div class=\"page-content\"><div class=\"info-grid\"><div class=\"info-card\"><h3>SNP Variants</h3><p>Over 42 million SNP variants catalogued from whole-genome sequencing across all accessions.</p></div><div class=\"info-card green\"><h3>Accessions</h3><p>1,001 rice accessions collected from 18 provinces across the Philippine archipelago.</p></div><div class=\"info-card gold\"><h3>Chromosomes</h3><p>All 12 rice chromosomes covered with high-density variant calls and quality filters applied.</p></div></div><h2>Genotype search interface</h2><p>Use the viewer below to search rice accessions by SNP marker, genomic region, or accession ID. Results can be exported for downstream analysis.</p><div style=\"width:100%;height:calc(100vh - 200px);min-height:800px;border-radius:6px;overflow:hidden;border:1px solid #e4d8d8;margin:24px 0;box-shadow:0 4px 20px rgba(0,0,0,0.08)\"><iframe src=\"https://snpseekv3.duckdns.org/1k1/1k1_prototype.zul\" width=\"100%\" height=\"100%\" frameborder=\"0\" allowfullscreen style=\"display:block\"></iframe></div><h2>Available datasets</h2><ul><li>Whole-genome SNP calls (VCF format, filtered)</li><li>Imputed genotype matrix for GWAS applications</li><li>Haplotype blocks and LD structure</li><li>Population structure and admixture coefficients</li></ul><span class=\"badge\">VCF</span><span class=\"badge green\">GWAS-ready</span><span class=\"badge gold\">Open Access</span></div>',
  'format' => 'full_html',
]);
\$n->set('path', ['alias' => '/data/genotype-viewer']);
\$n->status = 1;
\$n->save();

// ── JBrowse ───────────────────────────────────────────────────
\$jb_nodes = \Drupal::entityTypeManager()->getStorage('node')->loadByProperties(['title' => 'JBrowse Genome Browser']);
\$n2 = !empty(\$jb_nodes) ? reset(\$jb_nodes) : \Drupal\node\Entity\Node::create(['type' => 'page', 'title' => 'JBrowse Genome Browser']);

echo (empty(\$jb_nodes) ? 'Creating' : 'Updating') . ' JBrowse...' . PHP_EOL;
\$n2->set('body', [
  'value' => '<div class=\"page-hero\"><div class=\"page-hero-inner\"><div class=\"page-hero-tag\"><span>Data — JBrowse</span></div><h1>JBrowse Genome Browser</h1><p>Visualise the Philippine rice reference genome with gene annotations, SNP tracks, and expression data using the JBrowse 1 genome browser.</p></div></div><div class=\"page-content\"><div class=\"info-grid\"><div class=\"info-card\"><h3>Reference Genome</h3><p>Os-Nipponbare-Reference-IRGSP-1.0 — the gold-standard Oryza sativa reference sequence.</p></div><div class=\"info-card green\"><h3>Gene Annotations</h3><p>RAP-DB and MSU7 gene annotations including UTRs, introns, and functional descriptions.</p></div><div class=\"info-card gold\"><h3>Variant Tracks</h3><p>SNP density tracks for all 1,001 accessions overlaid on the reference genome coordinates.</p></div></div><h2>Genome browser</h2><p>Navigate the rice reference genome interactively. Pan and zoom across chromosomes, toggle annotation tracks, and inspect individual variant sites.</p><div style=\"width:100%;height:calc(100vh - 200px);min-height:800px;border-radius:6px;overflow:hidden;border:1px solid #e4d8d8;margin:24px 0;box-shadow:0 4px 20px rgba(0,0,0,0.08)\"><iframe src=\"https://brs-snpseek.duckdns.org/jbrowse/?loc=chr01%3A2902..10816&amp;tracks=DNA%2Cmsu7gff&amp;highlight=\" width=\"100%\" height=\"100%\" frameborder=\"0\" allowfullscreen style=\"display:block\"></iframe></div><h2>Available tracks</h2><ul><li>Reference sequence (IRGSP-1.0)</li><li>RAP-DB gene models</li><li>MSU7 gene annotations</li><li>SNP density — all 1,001 accessions</li><li>Repeat elements and transposons</li></ul><span class=\"badge\">IRGSP-1.0</span><span class=\"badge green\">RAP-DB</span><span class=\"badge green\">MSU7</span><span class=\"badge gold\">SNP Tracks</span></div>',
  'format' => 'full_html',
]);
\$n2->set('path', ['alias' => '/data/jbrowse']);
\$n2->status = 1;
\$n2->save();

// ── JBrowse2 ──────────────────────────────────────────────────
\$jb2_nodes = \Drupal::entityTypeManager()->getStorage('node')->loadByProperties(['title' => 'JBrowse2 Genome Browser']);
\$n3 = !empty(\$jb2_nodes) ? reset(\$jb2_nodes) : \Drupal\node\Entity\Node::create(['type' => 'page', 'title' => 'JBrowse2 Genome Browser']);

echo (empty(\$jb2_nodes) ? 'Creating' : 'Updating') . ' JBrowse2...' . PHP_EOL;
\$n3->set('body', [
  'value' => '<div class=\"page-hero\"><div class=\"page-hero-inner\"><div class=\"page-hero-tag\"><span>Data — JBrowse2</span></div><h1>JBrowse2 Genome Browser</h1><p>Next-generation genome visualisation using JBrowse 2 — featuring multi-genome comparison, structural variant views, dotplots, and a plugin-based architecture for extensibility.</p></div></div><div class=\"page-content\"><div class=\"info-grid\"><div class=\"info-card\"><h3>Multi-genome View</h3><p>Compare multiple rice genomes side by side — synteny, structural variants, and rearrangements visualised simultaneously.</p></div><div class=\"info-card green\"><h3>SV Support</h3><p>Structural variant tracks including insertions, deletions, inversions, and copy number variants from long-read sequencing.</p></div><div class=\"info-card gold\"><h3>Plugin Architecture</h3><p>Extensible plugin system allowing custom track types, data adapters, and visualisation widgets.</p></div></div><h2>Genome browser</h2><p>JBrowse 2 provides a modern React-based genome browser with multi-track and multi-genome comparison capabilities.</p><div style=\"width:100%;height:calc(100vh - 200px);min-height:800px;border-radius:6px;overflow:hidden;border:1px solid #e4d8d8;margin:24px 0;box-shadow:0 4px 20px rgba(0,0,0,0.08)\"><iframe src=\"https://brs-snpseek.duckdns.org/jbrowse2/?session=local-Okuh4ZhqgE-BsamEZOmCK\" width=\"100%\" height=\"100%\" frameborder=\"0\" allowfullscreen style=\"display:block\"></iframe></div><h2>New features in JBrowse 2</h2><ul><li>Linear genome view with multiple tracks</li><li>Circular (Circos-style) genome view</li><li>Dotplot view for whole-genome alignment comparison</li><li>Breakpoint split view for structural variant visualisation</li><li>Hi-C contact matrix view</li></ul><span class=\"badge\">React-based</span><span class=\"badge green\">SV Support</span><span class=\"badge green\">Multi-genome</span><span class=\"badge gold\">Plugin Ready</span></div>',
  'format' => 'full_html',
]);
\$n3->set('path', ['alias' => '/data/jbrowse2']);
\$n3->status = 1;
\$n3->save();
"

echo "==> Setting front page..."
docker compose exec -T web $DRUSH config:set system.site page.front /node/1 --yes

echo "==> Enabling theme..."
docker compose exec -T web $DRUSH en tripal --yes
docker compose exec -T web $DRUSH theme:enable phrice --yes
docker compose exec -T web $DRUSH config:set system.theme default phrice --yes

echo "==> Rebuilding cache..."
docker compose exec -T web $DRUSH cache:rebuild

echo "==> All pages created successfully."
