# Lightweight website verification

Local verification recorded on 2026-10-26 (Asia/Taipei), on branch `codex/lightweight-jekyll`, before publication. GitHub Pages settings are unchanged.

## Current page structure

The separate Repositories page was removed after the layout review because its projects duplicate Publications. Navigation now contains About, Publications, and CV. The repository page, data file, and dedicated styles are removed; publication code links and the GitHub profile link remain. The current verifier expects four HTML pages including 404 and checks that the removed page and navigation links are absent. Earlier measurements below describe the original migration checkpoint.

## Implementation

- Four main routes, the custom 404 page, and the existing CV PDF URL are preserved.
- Direct Gemfile dependencies: **22 → 3** (Jekyll, sitemap, WEBrick). The clean local installation resolved 37 gems including transitive dependencies.
- Site configuration: **574 → 36 lines**; layouts: **12 → 1**; includes: **54 → 4**; workflows: **10 → 1**.
- Publication data is shared between the homepage, Publications, and CV. Bibliography titles/years are the authoritative version where the former CV JSON differed; all four original CV summaries are preserved.
- No custom Ruby plugins, frontend scripts, external fonts, Bootstrap/MDB, remote repository cards, Docker, Jupyter, LSI or PurgeCSS remain in the site/build.
- Portrait and four previews were resized once to at most 720 pixels on the longest edge. Their existing paths are retained. The unused high-resolution alternate portrait is kept in source and excluded from the published site.

## Initial migration resource measurements

Measured in headless installed Google Chrome using Playwright, one fresh browser context per route, JavaScript enabled, 1280 × 900 viewport. Each page was scrolled through to load lazy images, then allowed to become network-idle. The baseline is the existing public website at `https://jamesqian1999.github.io`; the new site was served locally with Jekyll. Both runs completed without failed requests.

| Route | All requests | CSS requests | JS requests | CSS body bytes | JS body bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| `/` | 42 → 8 | 7 → 1 | 18 → 0 | 1,108,612 → 5,108 | 1,968,625 → 0 |
| `/publications/` | 33 → 7 | 7 → 1 | 18 → 0 | 1,108,612 → 5,108 | 1,968,625 → 0 |
| `/repositories/` | 32 → 3 | 7 → 1 | 18 → 0 | 1,108,612 → 5,108 | 1,968,625 → 0 |
| `/cv/` | 32 → 3 | 8 → 1 | 19 → 0 | 1,109,858 → 5,108 | 1,970,732 → 0 |

Bytes are sums of decoded response bodies obtained through the browser, not compressed transfer sizes. Request counts include document, font, image, and favicon traffic, and can vary with browser behavior. This is a resource-footprint comparison, not a claim about production latency, Lighthouse scores, or a percentage speed improvement. At the initial migration checkpoint, CSS totaled 5,108 bytes and no JavaScript was shipped. The visual refinement below supersedes that stylesheet size; the table is retained as the original measurement record.

## Checks passed

| Check | Result |
| --- | --- |
| Clean dependency installation | Bundler installed the new lockfile into a previously empty temporary directory using Ruby 3.4.2 / Bundler 2.6.3. |
| Frozen lockfile | `BUNDLE_FROZEN=true bundle check` passed. |
| Production build | `JEKYLL_ENV=production bundle exec jekyll build --trace` passed. |
| Site verifier | `bundle exec ruby scripts/verify.rb` passed: five pages, four papers, three repositories, local references, anchors, PDF, sitemap, active navigation and no script tags. |
| Data migration | All personal profile/CV fields and four summaries match the original JSON; author order and equal-contribution markers match all four original BibTeX records. Three repository URLs match. The PDF is byte-for-byte unchanged. |
| Single-source publication updates | In an isolated source copy, adding two YAML entries (selected/non-selected) updated the expected pages. Descending year groups, within-year author order, equal contribution and HTML escaping were checked. The original source data was not changed for this test. |
| Subpath compatibility | Built with `--baseurl /preview --destination /tmp/website-baseurl`; `scripts/verify.rb /tmp/website-baseurl /preview` passed. |
| Browser checks | All five pages passed at widths 1280, 390 and 320 pixels, with JavaScript disabled: no horizontal overflow, all images loaded, main headings present, skip-link keyboard navigation works. Main navigation and PDF returned correctly. An unknown route returned HTTP 404 with the custom page. |
| Visual inspection | Desktop homepage/repository layout and mobile homepage/publication/CV screenshots inspected; mobile papers use a full-width text column and footer does not cover content. |
| Workflow and whitespace | Workflow YAML parses; publication depends on the successful build/verification job. `git diff --check` passed. |

Browser automation was an implementation-time check, using the existing workspace runtime; it is not a Node dependency of the website or CI. The Ruby verifier is retained in the repository and runs in CI. Temporary browser measurements and screenshots are outside the source tree.

## Visual refinement after layout feedback

The CV now uses section navigation, date/content columns, restrained headings, and divider lines instead of repeated bordered cards. Long abstracts are retained inside native `details` elements, collapsed by default; no JavaScript was added. A prominent PDF download sits beside the page title. Shared typography, buttons, publication previews, social links, and footer spacing were refined across all pages.

- Production build and the Ruby verifier passed again after the styling/markup changes.
- The CV was visually checked in actual 1280px, 390px, and 320px iframe/browser viewports; the mobile About and Publications layouts were also inspected. Section links and abstract disclosure were exercised in the in-app browser.
- Responsive previews used a temporary generated-only HTML file, removed after inspection. No preview harness is included in the source or deployment.
- Current stylesheet size: **9570 bytes**. The site still ships one stylesheet and no JavaScript. Browser resource totals in the earlier table were not remeasured for this visual revision.

## Limits and release

- The GitHub Actions workflow has not been executed remotely. Linux is included in the lockfile; local checks were on macOS. The release workflow must pass for the published commit.
- External links were preserved and compared with source data; their destination content was not comprehensively audited.
- Biography wording was preserved, including the existing “under review” sentence. Updating current personal/research information is separate editorial work.
- PDF edits remain manual. The old template demo routes are intentionally removed; the sitemap contains only the four main pages.
- Release uses behavior-scoped commits rebased onto `origin/master`, followed by a normal push to `master`. Deployment results are recorded by GitHub Actions. The original site is recoverable from pre-migration commit `f2dfb6c`; reverting the migration restores the prior source and workflow.
