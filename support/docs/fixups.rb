class SitePage
  alias_method(:orig_contents, :contents)

  def contents()
    html = orig_contents()
    html = Nokogiri::HTML(html)

    # Manipulate links
    if source_filename == "index.md" || source_filename == "contributing.md"
      html.css("a").each do |anchor|
        anchor["href"] =
          case anchor["href"]
          when "CONTRIBUTING.html"
            "contributing.html"  
          when %r{^docs/}
            anchor["href"] = anchor["href"].sub(%r{docs/}, "")
          else
            anchor["href"]
          end
      end
    end

    html.to_s()
  end
end
