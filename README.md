# Cheng Chien 錢承 — personal website

A small, static Jekyll site with four pages: About, Publications, Repositories, and CV. Content is Markdown and YAML; one shared layout and one CSS file provide the presentation. All pages work without JavaScript.

## Local development

Use Ruby **3.4.2** (see `.ruby-version`) and Bundler **2.6.3**. macOS's system Ruby 2.6 is too old; use your Ruby version manager or Homebrew Ruby. There is no Node, Python, Docker, or ImageMagick build step.

```sh
bundle install
bundle exec jekyll serve
```

Open [http://localhost:4000](http://localhost:4000). Dependencies are locked in `Gemfile.lock` for macOS and Linux. When intentionally upgrading dependencies, update and review the lockfile with `bundle update`.

For a production build and the same checks used in CI:

```sh
JEKYLL_ENV=production bundle exec jekyll build --trace
bundle exec ruby scripts/verify.rb
```

`_site/` is generated output and is not committed. The verifier checks the five HTML pages (including 404), local links, image paths, anchors, shared publication data, PDF download, sitemap, and absence of JavaScript.

## Where to edit

| Change | Source |
| --- | --- |
| Biography and top skills | `_pages/about.md` |
| Name, contact details, social links, portrait, PDF path | `_data/profile.yml` |
| Education, volunteer experience, skills, languages, interests, awards | `_data/cv.yml` |
| Publications used by the homepage, Publications, and CV | `_data/publications.yml` |
| Repository cards | `_data/repositories.yml` |
| Navigation and site URL | `_config.yml` |
| Layout and reusable sections | `_layouts/default.liquid`, `_includes/` |
| Colors, spacing, mobile layout | `assets/css/site.css` |

The CV's Basics section reads `profile.yml`. Its Publications section reads `publications.yml`; do not copy publications into `cv.yml`. Social links reference fields in `profile.yml`, so changing the email or LinkedIn URL updates all uses automatically. The `name` field also controls which author name is emphasized.

### Add a publication

Add one entry to `_data/publications.yml`:

```yaml
- id: my-paper-2026
  title: "My paper title"
  authors:
    - First Author
    - Cheng Chien
  venue: Conference name
  year: 2026
  preview: /assets/img/publication_preview/my-paper.png
  selected: true
  links:
    - label: arXiv
      url: https://arxiv.org/abs/your-paper-id
    - label: Code
      url: https://github.com/your-account/your-project
  summary: >-
    A summary to display in the CV.
```

Use a unique `id` with letters, numbers, and hyphens. Keep authors in publication order; put `*` after an author's name for equal contribution. Use a numeric year and a boolean `selected`. Set `selected: false` to show the paper only on Publications and CV. Pages group papers by descending year, preserving YAML order within each year. `summary` is optional and appears in a native, expandable “Read abstract” section on the CV. Keep at least one link; the first is used for the CV title link. Quote titles containing `: `.

Add the preview image at the specified path. The existing images are pre-sized static assets; there is no image processing during deployment. A preview around 720 pixels on its longest edge is sufficient for this layout. Use a descriptive preview showing the work, rather than a decorative image.

### Update the CV or PDF

Edit `_data/cv.yml` for the HTML CV, and `_data/profile.yml` for contact details. Quote date strings such as `"2023-05-21"`. Keep downloadable PDF updates manual: replace `assets/pdf/ChengChien_CV.pdf` with the new document. Its public URL stays unchanged. Updating the HTML CV does not regenerate the PDF.

### Add a repository

Add a `name`, `owner`, and full GitHub `url` to `_data/repositories.yml`. Cards are rendered locally without external stats images or API calls.

## Deployment and rollback

The single workflow in `.github/workflows/deploy.yml` builds and validates pull requests. Successful pushes to `master` or `main` publish the checked artifact to the existing `gh-pages` branch. The workflow may also be started manually on either primary branch. PRs and feature branches cannot publish. Keep the existing GitHub Pages publishing source pointed at `gh-pages`.

The public routes remain `/`, `/publications/`, `/repositories/`, `/cv/`, `/404.html`, and `/assets/pdf/ChengChien_CV.pdf`. Old template demo posts, projects, and news routes are intentionally removed. No custom domain or Pages source change is part of this migration.

Preview the migration before release. Rebase its commits onto `origin/master`, then push `master` without force. To roll back a published migration, revert its changes on the primary branch and let the previous workflow rebuild the original site. The original files remain recoverable in Git history.

Verification results and the resource comparison are recorded in `docs/verification.md`.

## License

The original al-folio MIT license is retained in `LICENSE`.
