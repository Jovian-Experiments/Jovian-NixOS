#!/usr/bin/env ruby

require_relative "lib"

require "fileutils"

if ARGV.length < 3 then
  $stderr.puts "Usage: main.rb <template_dir> <source dir> <output dir>"
  exit 1
end

$template_dir = ARGV.shift
$source = ARGV.shift
$output = ARGV.shift

SitePage.template_location = $template_dir

files = Dir.glob(File.join($source, "**/*.md"))

# Used to collect all pages
sitemap = []

files.each do |filename|
  relative_name = filename.sub(%r{^#{$source}}, "")
  $stderr.puts "\n⇒ processing #{relative_name}"

  markdown_document = MarkdownDocument.from_filename(filename)
  page = SitePage.new(markdown_document, relative_name, source_filename: relative_name)
  FileUtils.mkdir_p(File.dirname(page.output_name))
  page.write()
  sitemap << [page.relative_output, page]
end

generate_sitemap(sitemap)

$stderr.puts("\n\n\nDone!\n\n")
