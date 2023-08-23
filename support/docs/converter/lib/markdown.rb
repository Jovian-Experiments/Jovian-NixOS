require "open3"
require "shellwords"

class MarkdownDocument
  def initialize(contents)
    @contents = contents
  end

  def self.from_filename(filename)
    self.new(File.read(filename))
  end

  # HTML output from markdown.
  def to_html()
    @html ||= cmark("--to", "html")
    @html
  end

  # XML representation of the raw markdown, unrelated to the HTML output.
  def to_xml()
    @xml ||= Nokogiri::XML(cmark("--to", "xml"))
    @xml
  end

  # Returns the first h1-level heading
  def title()
    el = Nokogiri::HTML(to_html).at_css("h1")
    raise "No level-1 heading in document." if el.nil? || el.text.blank?
    el.text
  end

  def cmark(*args)
    cmd = [
      "cmark-gfm",
      "--unsafe",
      "--extension", "table",
      "--extension", "autolink",
      "--extension", "footnotes",
      "--extension", "strikethrough",
      "--extension", "autolink",
      *args
    ]
    output, err, status = Open3.capture3(*cmd, stdin_data: @contents)
    unless status.success?
      $stderr.puts(output)
      $stderr.puts(err)
      raise "Error running #{cmd.shelljoin}..."
    end

    output
  end
end
