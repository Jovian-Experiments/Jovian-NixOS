#!/usr/bin/env ruby

require_relative "lib"

require "json"

$level = 2
$namespace = ""

begin
  unused = []
  while opt = ARGV.shift
    case opt
    when /^--level/
      $level = ARGV.shift.to_i
    when /^--namespace/
      $namespace = ARGV.shift
    when /^-/
      $stderr.puts "Unexepected parameter: #{opt}"
      exit 2
    else
      unused << opt
    end
  end

  if unused.length < 3 then
    $stderr.puts "Usage: main.rb <template_dir> <options.json> <page.md|page.html>"
    exit 1
  end

  $template_dir = unused.shift
  $optionsJSON = unused.shift
  $output_file = unused.shift
end

options = JSON.parse(File.read($optionsJSON))

options = options.to_a.sort do |a, b|
  a.first <=> b.first
end

options.select! do |pair|
  pair.first.match(/^#{$namespace}/)
end

out = File.open($output_file, "a")

$template = ERB.new(File.read(File.join($template_dir, "option.erb")))

options.each do |pair|
  name, data = pair
  data["h_name"] = "h#{$level}"
  data["h_option"] = "h#{$level+1}"
  data["name"] = name
  data["declaration"] = data["declarations"].first
  data["description"] = MarkdownDocument.new(data["description"]).to_html

  blurb = $template.result_with_hash(data)

  # Strip leading spaces because markdown will interpret as code even though it's within HTML
  blurb =
    blurb
    .strip
    .gsub(/^\s+/, "")

  out.puts(blurb)
end
