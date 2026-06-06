module Components
  class Palette
    COLORS = ["#FF5436", "#F5A623", "#FF5E8A", "#9B6FB0", "#2E8FE8", "#12A89D", "#3FA86A", "#C56A3C"].freeze

    def hex(index)
      return COLORS.first if index.zero?

      rest = COLORS.drop(1)
      rest[(index - 1) % rest.size]
    end
  end
end
