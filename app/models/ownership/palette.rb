module Ownership::Palette
  extend ActiveSupport::Concern

  included do
    before_validation :assign_color, on: :create
  end

  private

  # Stable identity color as a plain integer palette index (the view maps it to a hex
  # and cycles, so albums aren't capped). The creator gets 0; everyone else the next index.
  def assign_color
    return if color.present?
    return unless album

    self.color = creator? ? 0 : album.ownerships.maximum(:color).to_i + 1
  end
end
