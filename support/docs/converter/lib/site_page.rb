require "erb"
require "nokogiri"

class SitePage
  def self.template_location=(value)
    @@template_location = value
  end

  def initialize(markdown_document, output_name, source_filename: nil)
    @markdown_document = markdown_document
    @output_name = output_name
    @source_filename = source_filename
  end

  # Used in `<base href="" />`.
  def document_base()
    out_dir = File.dirname(@output_name)
    case out_dir
    when "."
      "."
    else
      parts = out_dir.split("/")
      parts.map { ".." }.join("/").tap do |x| pp x end
    end
  end

  def relative_output()
   @output_name.sub(%r{#{".md"}$}, ".html")
  end

  def output_name()
    File.join($output, relative_output)
  end

  def source_filename()
    @source_filename
  end

  def page_class()
    relative_output.sub(/[^a-z0-9]/, "-").sub(/\.html/, "")
  end

  # Use in `<title>` or anywhere else relevant.
  def title()
    @markdown_document.title()
  end

  # Use where the contents should be displayed.
  def contents()
    html = Nokogiri::HTML(@markdown_document.to_html())

    # Fixup refs to other markdown documents
    html.css("a").each do |anchor|
      anchor["href"] = anchor["href"].sub(%r{\.md$}, ".html")
    end

    # Since Nokogiri produces a complete document from our fragment, we
    # have to pick only what's in the body; so strip the body added tags and higher-up tags.
    html
      .at_css("body").to_s()
      .sub(%r{^<body>}, "").sub(%r{</body>$}, "")
  end

  # Writes the HTML document to the given filename.
  def write()
    template = ERB.new(File.read(File.join(@@template_location, "main.erb")))
    file_contents = template.result(self.binding())
    File.write(output_name, file_contents)
  end
end
