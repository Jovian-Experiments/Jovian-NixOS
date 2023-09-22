#!/usr/bin/env ruby

require_relative "lib"

require "json"

$level = 2

begin
  unused = []
  while opt = ARGV.shift
    case opt
    when /^--level/
      $level = ARGV.shift.to_i
    when /^-/
      $stderr.puts "Unexepected parameter: #{opt}"
      exit 2
    else
      unused << opt
    end
  end

  if unused.length < 3 then
    $stderr.puts "Usage: main.rb <template_dir> <packages.json> <page.md|page.html>"
    exit 1
  end

  $template_dir = unused.shift
  $packagesJSON = unused.shift
  $output_file = unused.shift
end

packages = JSON.parse(File.read($packagesJSON))

packages = packages.to_a.sort do |a, b|
  a.first <=> b.first
end

out = File.open($output_file, "a")

$template = ERB.new(File.read(File.join($template_dir, "package.erb")))

packages.each do |pair|
  attrname, data = pair
  next unless data["entry_type"] == "package"

  data["h_name"] = "h#{$level}"
  data["h_package"] = "h#{$level+1}"
  data["attrname"] = attrname
  #data["declaration"] = data["declarations"].first
  #data["description"] = MarkdownDocument.new(data["description"]).to_html

  blurb = $template.result_with_hash(data)

  # Strip leading spaces because markdown will interpret as code even though it's within HTML
  blurb =
    blurb
    .strip
    .gsub(/^\s+/, "")

  out.puts(blurb)
end
