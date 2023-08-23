def generate_sitemap(sitemap)
  list = sitemap.sort{ |a, b| a.first <=> b.first }.map do |pair|
    filename, page = pair
    " | `#{filename}` | [#{page.title}](#{filename}) |"
  end

  # We don't have a hierarchy for subfolders.
  # So since this makes the sitemap unwieldy to use, we're using
  # a simple table with file path to clearly show what's where.
  document = [
    "# Site Map",
    "",
    "| Path | Page title |",
    "| ---- | ---------- |",
    list.join("\n"),
    "",
  ].join("\n")

  markdown_document = MarkdownDocument.new(document)

  page = SitePage.new(markdown_document, "sitemap.md")
  page.write()
end
