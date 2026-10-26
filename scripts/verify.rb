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
puts "PASS: #{pages.size} pages, #{papers.size} publications, local references, anchors, PDF, sitemap, no Repositories page, and JavaScript-free output."
