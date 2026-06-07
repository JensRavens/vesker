module Components
  class Field < Base
    TYPES = [:text, :email, :code].freeze

    prop :name, String
    prop :id, String
    prop :type, _Union(*TYPES), default: :text
    prop :options, Hash, default: -> { {} }

    def view_template
      input(type: input_type, name: @name, id: @id, class: css, **@options)
    end

    private

    # A code field is a styled text input.
    def input_type
      (@type == :code) ? :text : @type
    end

    def css
      (@type == :code) ? "field field--code" : "field"
    end
  end
end
