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
  'value' => '<div class=\"page-hero\"><div class=\"page-hero-inner\"><div class=\"page-hero-tag\"><span>Data — Genotype Viewer</span></div><h1>Genotype Viewer</h1><p>Explore and compare genotypic data across 1,001 Philippine rice accessions. Filter by chromosome, position, or accession to visualise SNP variants across the collection.</p></div></div><div class=\"page-content\" style=\"max-width:100%;padding-left:clamp(16px,13%,200px);padding-right:clamp(16px,13%,200px)\"><div class=\"info-grid\"><div class=\"info-card\"><h3>SNP Variants</h3><p>Over 42 million SNP variants catalogued from whole-genome sequencing across all accessions.</p></div><div class=\"info-card green\"><h3>Accessions</h3><p>1,001 rice accessions collected from 18 provinces across the Philippine archipelago.</p></div><div class=\"info-card gold\"><h3>Chromosomes</h3><p>All 12 rice chromosomes covered with high-density variant calls and quality filters applied.</p></div></div><h2>Genotype search interface</h2><p>Use the viewer below to search rice accessions by SNP marker, genomic region, or accession ID. Results can be exported for downstream analysis.</p><div style=\"width:100%;height:calc(100vh - 200px);min-height:800px;border-radius:6px;overflow:hidden;border:1px solid #e4d8d8;margin:24px 0;box-shadow:0 4px 20px rgba(0,0,0,0.08)\"><iframe src=\"https://snpseekv3.duckdns.org/1k1/1k1_prototype.zul\" width=\"100%\" height=\"100%\" frameborder=\"0\" allowfullscreen style=\"display:block\"></iframe></div><h2>Available datasets</h2><ul><li>Whole-genome SNP calls (VCF format, filtered)</li><li>Imputed genotype matrix for GWAS applications</li><li>Haplotype blocks and LD structure</li><li>Population structure and admixture coefficients</li></ul><span class=\"badge\">VCF</span><span class=\"badge green\">GWAS-ready</span><span class=\"badge gold\">Open Access</span></div>',
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
  'value' => '<div class=\"page-hero\"><div class=\"page-hero-inner\"><div class=\"page-hero-tag\"><span>Data — JBrowse</span></div><h1>JBrowse Genome Browser</h1><p>Visualise the Philippine rice reference genome with gene annotations, SNP tracks, and expression data using the JBrowse 1 genome browser.</p></div></div><div class=\"page-content\" style=\"max-width:100%;padding-left:clamp(16px,13%,200px);padding-right:clamp(16px,13%,200px)\"><div class=\"info-grid\"><div class=\"info-card\"><h3>Reference Genome</h3><p>Os-Nipponbare-Reference-IRGSP-1.0 — the gold-standard Oryza sativa reference sequence.</p></div><div class=\"info-card green\"><h3>Gene Annotations</h3><p>RAP-DB and MSU7 gene annotations including UTRs, introns, and functional descriptions.</p></div><div class=\"info-card gold\"><h3>Variant Tracks</h3><p>SNP density tracks for all 1,001 accessions overlaid on the reference genome coordinates.</p></div></div><h2>Genome browser</h2><p>Navigate the rice reference genome interactively. Pan and zoom across chromosomes, toggle annotation tracks, and inspect individual variant sites.</p><div style=\"width:100%;height:calc(100vh - 200px);min-height:800px;border-radius:6px;overflow:hidden;border:1px solid #e4d8d8;margin:24px 0;box-shadow:0 4px 20px rgba(0,0,0,0.08)\"><iframe src=\"https://brs-snpseek.duckdns.org/jbrowse/?loc=chr01%3A2902..10816&amp;tracks=DNA%2Cmsu7gff&amp;highlight=\" width=\"100%\" height=\"100%\" frameborder=\"0\" allowfullscreen style=\"display:block\"></iframe></div><h2>Available tracks</h2><ul><li>Reference sequence (IRGSP-1.0)</li><li>RAP-DB gene models</li><li>MSU7 gene annotations</li><li>SNP density — all 1,001 accessions</li><li>Repeat elements and transposons</li></ul><span class=\"badge\">IRGSP-1.0</span><span class=\"badge green\">RAP-DB</span><span class=\"badge green\">MSU7</span><span class=\"badge gold\">SNP Tracks</span></div>',
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
  'value' => '<div class=\"page-hero\"><div class=\"page-hero-inner\"><div class=\"page-hero-tag\"><span>Data — JBrowse2</span></div><h1>JBrowse2 Genome Browser</h1><p>Next-generation genome visualisation using JBrowse 2 — featuring multi-genome comparison, structural variant views, dotplots, and a plugin-based architecture for extensibility.</p></div></div><div class=\"page-content\" style=\"max-width:100%;padding-left:clamp(16px,13%,200px);padding-right:clamp(16px,13%,200px)\"><div class=\"info-grid\"><div class=\"info-card\"><h3>Multi-genome View</h3><p>Compare multiple rice genomes side by side — synteny, structural variants, and rearrangements visualised simultaneously.</p></div><div class=\"info-card green\"><h3>SV Support</h3><p>Structural variant tracks including insertions, deletions, inversions, and copy number variants from long-read sequencing.</p></div><div class=\"info-card gold\"><h3>Plugin Architecture</h3><p>Extensible plugin system allowing custom track types, data adapters, and visualisation widgets.</p></div></div><h2>Genome browser</h2><p>JBrowse 2 provides a modern React-based genome browser with multi-track and multi-genome comparison capabilities.</p><div style=\"width:100%;height:calc(100vh - 200px);min-height:800px;border-radius:6px;overflow:hidden;border:1px solid #e4d8d8;margin:24px 0;box-shadow:0 4px 20px rgba(0,0,0,0.08)\"><iframe src=\"https://brs-snpseek.duckdns.org/jbrowse2/?session=share-0HdpgD5_78&password=Q1KjB\" width=\"100%\" height=\"100%\" frameborder=\"0\" allowfullscreen style=\"display:block\"></iframe></div><h2>New features in JBrowse 2</h2><ul><li>Linear genome view with multiple tracks</li><li>Circular (Circos-style) genome view</li><li>Dotplot view for whole-genome alignment comparison</li><li>Breakpoint split view for structural variant visualisation</li><li>Hi-C contact matrix view</li></ul><span class=\"badge\">React-based</span><span class=\"badge green\">SV Support</span><span class=\"badge green\">Multi-genome</span><span class=\"badge gold\">Plugin Ready</span></div>',
  'format' => 'full_html',
]);
\$n3->set('path', ['alias' => '/data/jbrowse2']);
\$n3->status = 1;
\$n3->save();


// ── Data index ────────────────────────────────────────────────
\$data_nodes = \Drupal::entityTypeManager()->getStorage('node')->loadByProperties(['title' => 'Data']);
\$nd = !empty(\$data_nodes) ? reset(\$data_nodes) : \Drupal\node\Entity\Node::create(['type' => 'page', 'title' => 'Data']);

echo (empty(\$data_nodes) ? 'Creating' : 'Updating') . ' Data index...' . PHP_EOL;
\$nd->set('body', [
  'value' => '<div class=\"page-hero\"><div class=\"page-hero-inner\"><div class=\"page-hero-tag\"><span>Data</span></div><h1>Data &amp; Datasets</h1><p>Access genomic datasets, SNP variant calls, and interactive browsers for the 1,001 Philippine rice accessions.</p></div></div><div class=\"page-content\"><div class=\"placeholder-notice\"><div class=\"placeholder-icon\">⚠</div><div><strong>Placeholder content — this page will be updated soon.</strong><p>The content on this page is temporary. Full dataset documentation and download links are currently being prepared.</p></div></div><div class=\"info-grid\"><div class=\"info-card\"><h3>Genotype Viewer</h3><p>Search and compare SNP variants across all 1,001 accessions using the SNP-Seek genotype interface.</p></div><div class=\"info-card green\"><h3>JBrowse</h3><p>Explore the IRGSP-1.0 reference genome with RAP-DB and MSU7 annotations in JBrowse 1.</p></div><div class=\"info-card gold\"><h3>JBrowse2</h3><p>Next-generation genome browser with multi-genome comparison, SV tracks, and plugin support.</p></div></div><h2>Available data resources</h2><p>The portal provides access to the following datasets generated from whole-genome sequencing of 1,001 Philippine rice accessions collected across 18 provinces.</p><ul><li><a href=\"/ph_gdb/data/genotype-viewer\">Genotype Viewer</a> — Interactive SNP search across all accessions</li><li><a href=\"/ph_gdb/data/jbrowse\">JBrowse Genome Browser</a> — Reference genome and annotation tracks</li><li><a href=\"/ph_gdb/data/jbrowse2\">JBrowse2 Genome Browser</a> — Multi-genome and structural variant views</li></ul><h2>Data access &amp; downloads</h2><p>Bulk dataset downloads, VCF files, and API access documentation are currently being finalised and will be made available here.</p><span class=\"badge\">VCF</span><span class=\"badge green\">FASTA</span><span class=\"badge gold\">Open Access</span></div>',
  'format' => 'full_html',
]);
\$nd->set('path', ['alias' => '/data']);
\$nd->status = 1;
\$nd->save();

// ── Tools ─────────────────────────────────────────────────────
\$tools_nodes = \Drupal::entityTypeManager()->getStorage('node')->loadByProperties(['title' => 'Tools']);
\$nt = !empty(\$tools_nodes) ? reset(\$tools_nodes) : \Drupal\node\Entity\Node::create(['type' => 'page', 'title' => 'Tools']);

echo (empty(\$tools_nodes) ? 'Creating' : 'Updating') . ' Tools...' . PHP_EOL;
\$nt->set('body', [
  'value' => '<div class=\"page-hero\"><div class=\"page-hero-inner\"><div class=\"page-hero-tag\"><span>Tools</span></div><h1>Bioinformatics Tools</h1><p>Analytical and visualisation tools for exploring the genetic diversity of Philippine rice varieties.</p></div></div><div class=\"page-content\"><div class=\"placeholder-notice\"><div class=\"placeholder-icon\">⚠</div><div><strong>Placeholder content — this page will be updated soon.</strong><p>The tools listed below are planned or under active development. Documentation and links will be added as each tool becomes available.</p></div></div><div class=\"info-grid\"><div class=\"info-card\"><h3>BLAST Search</h3><p>Sequence similarity search against the Philippine rice genome and annotated gene models.</p></div><div class=\"info-card green\"><h3>Population Structure</h3><p>Visualise admixture coefficients, PCA plots, and phylogenetic relationships across accessions.</p></div><div class=\"info-card gold\"><h3>GWAS Toolkit</h3><p>Genome-wide association analysis using the imputed genotype matrix and phenotypic data.</p></div></div><h2>Planned tools</h2><p>The following bioinformatics tools are planned for integration into the portal. Each tool will link to its own dedicated page once deployed.</p><ul><li>BLAST — nucleotide and protein sequence search</li><li>Synteny viewer — cross-genome synteny and collinearity</li><li>Haplotype network — visualise haplotype diversity per gene region</li><li>GWAS portal — genome-wide association study interface</li><li>Population structure viewer — PCA, admixture, and phylogenetics</li></ul><h2>External tools</h2><p>Integrated third-party tools are accessible via the Data menu. These include the SNP-Seek Genotype Viewer, JBrowse, and JBrowse2 genome browsers.</p></div>',
  'format' => 'full_html',
]);
\$nt->set('path', ['alias' => '/tools']);
\$nt->status = 1;
\$nt->save();

// ── Publications ──────────────────────────────────────────────
\$pub_nodes = \Drupal::entityTypeManager()->getStorage('node')->loadByProperties(['title' => 'Publications']);
\$np = !empty(\$pub_nodes) ? reset(\$pub_nodes) : \Drupal\node\Entity\Node::create(['type' => 'page', 'title' => 'Publications']);

echo (empty(\$pub_nodes) ? 'Creating' : 'Updating') . ' Publications...' . PHP_EOL;
\$np->set('body', [
  'value' => '<div class=\"page-hero\"><div class=\"page-hero-inner\"><div class=\"page-hero-tag\"><span>Publications</span></div><h1>Publications</h1><p>Peer-reviewed research, data papers, and technical reports arising from the 1001 Philippine Rice Genome project.</p></div></div><div class=\"page-content\"><div class=\"placeholder-notice\"><div class=\"placeholder-icon\">⚠</div><div><strong>Placeholder content — this page will be updated soon.</strong><p>A curated list of project publications and citation guidelines will be added here. Please check back later.</p></div></div><h2>Project publications</h2><p>Publications directly associated with the 1001 Philippine Rice Genome project will be listed here, including the primary data paper, methodology articles, and downstream analyses.</p><h2>How to cite</h2><p>If you use data from this portal in your research, citation details will be provided here. A formal data paper describing the project, sequencing methods, and variant calling pipeline is currently in preparation.</p><h2>Related resources</h2><ul><li>SNP-Seek Database — <a href=\"https://snpseek.irri.org\" target=\"_blank\" rel=\"noopener noreferrer\">snpseek.irri.org</a></li><li>International Rice Genome Sequencing Project (IRGSP-1.0)</li><li>RAP-DB — Rice Annotation Project Database</li><li>MSU Rice Genome Annotation Project</li></ul><span class=\"badge\">Open Access</span><span class=\"badge green\">Peer-reviewed</span></div>',
  'format' => 'full_html',
]);
\$np->set('path', ['alias' => '/publications']);
\$np->status = 1;
\$np->save();

// ── About ─────────────────────────────────────────────────────
\$about_nodes = \Drupal::entityTypeManager()->getStorage('node')->loadByProperties(['title' => 'About']);
\$na = !empty(\$about_nodes) ? reset(\$about_nodes) : \Drupal\node\Entity\Node::create(['type' => 'page', 'title' => 'About']);

echo (empty(\$about_nodes) ? 'Creating' : 'Updating') . ' About...' . PHP_EOL;
\$na->set('body', [
  'value' => '<div class=\"page-hero\"><div class=\"page-hero-inner\"><div class=\"page-hero-tag\"><span>About</span></div><h1>About the Portal</h1><p>Background, objectives, and the team behind the 1001 Philippine Rice Genome Portal.</p></div></div><div class=\"page-content\"><div class=\"placeholder-notice\"><div class=\"placeholder-icon\">⚠</div><div><strong>Placeholder content — this page will be updated soon.</strong><p>Detailed project background, team profiles, and funding acknowledgements are currently being compiled and will appear here.</p></div></div><h2>Project overview</h2><p>The 1001 Philippine Rice Genome Portal is a Tripal-powered bioinformatics platform developed to catalogue, manage, and share whole-genome sequencing data of rice varieties collected across the Philippine archipelago.</p><p>The project aims to document the genetic diversity of 1,001 traditional and heirloom Philippine rice varieties, providing a publicly accessible resource to support breeding programmes, conservation efforts, and food security research.</p><h2>Objectives</h2><ul><li>Generate high-quality whole-genome sequence data for 1,001 Philippine rice accessions</li><li>Identify and catalogue SNP variants, structural variants, and gene presence/absence variation</li><li>Provide open-access genomic data through an interactive web portal</li><li>Support downstream applications in plant breeding, GWAS, and conservation genomics</li></ul><h2>Partners &amp; collaborators</h2><div class=\"info-grid\"><div class=\"info-card\"><h3>University of the Philippines System</h3><p>Lead institution overseeing project coordination, data management, and portal development.</p></div><div class=\"info-card green\"><h3>IRRI — Bioinformatics Unit</h3><p>Provides bioinformatics infrastructure, sequencing support, and the SNP-Seek platform integration.</p></div><div class=\"info-card gold\"><h3>DA-PhilRice</h3><p>Contributes rice germplasm, field collection expertise, and national breeding programme linkages.</p></div></div><h2>Funding</h2><p>Funding information and acknowledgements will be added here upon publication.</p><h2>Contact</h2><p>For enquiries about data access, collaboration, or the portal, please use the <a href=\"/ph_gdb/contact\">contact page</a>.</p></div>',
  'format' => 'full_html',
]);
\$na->set('path', ['alias' => '/about']);
\$na->status = 1;
\$na->save();
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
