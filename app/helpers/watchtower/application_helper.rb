# frozen_string_literal: true

module Watchtower
  module ApplicationHelper
    def watchtower_favicon_data_uri
      svg_path = File.join(
        Watchtower::Engine.root,
        'app/assets/images/watchtower/watchtower_icon.svg'
      )
      svg_content = File.read(svg_path)
      encoded = Base64.strict_encode64(svg_content)
      "data:image/svg+xml;base64,#{encoded}"
    end
  end
end
