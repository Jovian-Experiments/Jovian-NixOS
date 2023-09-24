require_relative "lib/markdown"
require_relative "lib/site_page"
require_relative "lib/sitemap"

class String
  def blank?
    self.match(/^\s+$/)
  end
end
