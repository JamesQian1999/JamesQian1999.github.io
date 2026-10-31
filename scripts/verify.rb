# frozen_string_literal: true

require "cgi"
require "pathname"
require "uri"
require "yaml"
require "rexml/document"

root = Pathname.new(__dir__).parent
site = Pathname.new(ARGV.fetch(0, root.join("_site").to_s)).expand_path
baseurl = ARGV.fetch(1, "")
errors = []
check = ->(condition, message) { errors << message unless condition }
pages = ["index.html", "publications/index.html", "cv/index.html", "404.html"]
pages.each { |path| check.call(site.join(path).file?, "Missing page: #{path}") }
check.call(!site.join("repositories/index.html").exist?, "Removed Repositories page still exists")
abort errors.join("\n") unless errors.empty?

html_pages = site.glob("**/*.html")
check.call(html_pages.size == pages.size, "Unexpected template or demo pages in output")
html_pages.each do |file|
  html = file.read
  relative = file.relative_path_from(site).to_s
  check.call(html.scan(/<h1\b/).size == 1, "#{relative}: expected one main heading")
  check.call(!html.match?(/\{[{%]/), "#{relative}: unrendered template syntax")
  check.call(!html.match?(/<script\b/i), "#{relative}: unexpected JavaScript")
  check.call(!html.include?("/repositories/"), "#{relative}: removed Repositories link remains")
  ids = html.scan(/\bid="([^"]+)"/).flatten
  check.call(ids.uniq == ids, "#{relative}: duplicate HTML IDs")
  check.call(html.include?('href="#main"'), "#{relative}: missing skip link")
  check.call(html.include?('aria-current="page"'), "#{relative}: missing active navigation") unless relative == "404.html"

  html.scan(/\b(?:href|src)="([^"]+)"/).flatten.each do |value|
    value = CGI.unescapeHTML(value)
    next if value.match?(/\A(?:[a-z][a-z0-9+.-]*:|\/\/)/i)

    path, fragment = value.split("#", 2)
    path = URI::DEFAULT_PARSER.unescape(path.split("?", 2).first || "")
    if path.start_with?("/")
      check.call(baseurl.empty? || path.start_with?("#{baseurl}/"), "#{relative}: missing baseurl in #{value}")
      path = path.delete_prefix(baseurl) unless baseurl.empty?
      target = site.join(path.delete_prefix("/"))
    else
      target = path.empty? ? file : file.dirname.join(path)
    end
    target = target.join("index.html") if target.directory?
    check.call(target.file?, "#{relative}: broken local reference #{value}")
    next unless fragment && target.file? && target.extname == ".html"

    fragment = URI::DEFAULT_PARSER.unescape(fragment)
    check.call(target.read.include?("id=\"#{fragment}\""), "#{relative}: missing anchor #{value}")
  end
end

papers = YAML.safe_load_file(root.join("_data/publications.yml"))
check.call(papers.map { |paper| paper.fetch("id") }.uniq.size == papers.size, "Duplicate publication IDs")
publications = site.join("publications/index.html").read
cv = site.join("cv/index.html").read
home = site.join("index.html").read
papers.each do |paper|
  title = CGI.escapeHTML(paper.fetch("title"))
  check.call(publications.include?(title) && cv.include?(title), "Publication missing from publications/CV: #{paper['id']}")
  check.call(home.include?(title) == paper.fetch("selected"), "Incorrect homepage selection: #{paper['id']}")
  paper.fetch("authors").each do |author|
    check.call(publications.include?(CGI.escapeHTML(author)), "Missing author #{author}")
  end
  paper.fetch("links").each do |link|
    check.call(publications.include?(CGI.escapeHTML(link.fetch("url"))), "Missing publication link #{link['url']}")
  end
end
profile = YAML.safe_load_file(root.join("_data/profile.yml"))
check.call(site.join(profile.fetch("cv_pdf").delete_prefix("/")).read(5) == "%PDF-", "CV download is not a PDF")
check.call(home.include?(CGI.escapeHTML(profile.fetch("summary"))) && cv.include?(CGI.escapeHTML(profile.fetch("summary"))), "Shared professional summary missing from homepage/CV")

resume = YAML.safe_load_file(root.join("_data/cv.yml"))
work = resume.fetch("work", [])
unless work.empty?
  work_sections = {
    "homepage" => home[/<section\b[^>]*aria-labelledby="home-experience-heading"[^>]*>.*?<\/section>/m],
    "CV" => cv[/<section\b[^>]*id="experience"[^>]*>.*?<\/section>/m]
  }
  work_sections.each do |page, section|
    check.call(section, "#{page}: missing Work Experience section")
    next unless section

    expected_count = 0
    work.each do |entry|
      highlights = entry.fetch("highlights")
      highlights = highlights.select { |highlight| highlight.fetch("featured") } if page == "homepage"
      next if highlights.empty?

      %w[name position startDate endDate employmentType location].each do |field|
        check.call(section.include?(CGI.escapeHTML(entry.fetch(field))), "#{page}: missing work #{field}")
      end
      highlights.group_by { |highlight| highlight.fetch("area") }.each do |area, items|
        check.call(section.include?("<h4>#{CGI.escapeHTML(area)}</h4>"), "#{page}: missing capability #{area}")
        items.each do |highlight|
          check.call(section.include?("<li>#{CGI.escapeHTML(highlight.fetch('text'))}</li>"), "#{page}: missing work highlight in #{area}")
        end
      end
      expected_count += highlights.size
    end
    check.call(section.scan(/<li>/).size == expected_count, "#{page}: incorrect work highlight selection/count")
  end
  check.call(home.include?("href=\"#{baseurl}/cv/#experience\""), "Homepage: missing full experience link")
  check.call(cv.include?('href="#experience"'), "CV: missing experience navigation link")
  check.call(home.index('aria-labelledby="home-experience-heading"').to_i < home.index('aria-labelledby="selected-heading"').to_i, "Homepage: experience must precede publications")
  check.call(cv.index('id="basics"').to_i < cv.index('id="experience"').to_i && cv.index('id="experience"').to_i < cv.index('id="education"').to_i, "CV: experience must follow Overview and precede Education")
end

sitemap = REXML::Document.new(site.join("sitemap.xml").read)
locations = REXML::XPath.match(sitemap, "//*[local-name()='loc']").map(&:text)
config = YAML.safe_load_file(root.join("_config.yml"))
site_url = config.fetch("url") + baseurl
%w[/ /publications/ /cv/].each do |route|
  check.call(locations.include?(site_url + route), "Missing sitemap route #{route}")
end
check.call(locations.none? { |url| url.include?("/assets/") || url.end_with?("/404.html") }, "Sitemap includes assets or 404")
check.call(locations.none? { |url| url.include?("/repositories/") }, "Sitemap includes removed Repositories page")

abort errors.join("\n") unless errors.empty?
puts "PASS: #{pages.size} pages, #{papers.size} publications, shared summary/work experience, local references, anchors, PDF, sitemap, no Repositories page, and JavaScript-free output."
