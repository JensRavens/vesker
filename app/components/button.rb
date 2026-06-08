module Components
  class Button < Base
    VARIANTS = [:primary, :ghost, :danger].freeze
    TYPES = [:button, :submit].freeze

    prop :variant, _Union(*VARIANTS), default: :primary
    prop :type, _Union(*TYPES), default: :button
    prop :href, _Nilable(String), default: nil
    prop :data, _Nilable(_Hash(Symbol, String)), default: nil
    prop :disabled, _Boolean, default: false
    prop :value, _Nilable(String), default: nil

    # A link when `href:` is given, otherwise a button. `data:` carries any Stimulus
    # bindings (e.g. the modal-close action on a ghost dismiss button); `value:` lets a
    # dialog-form submit report which button was pressed.
    def view_template(&)
      if @href
        a(href: @href, class: css, &)
      else
        button(type: @type, class: css, data: @data, disabled: @disabled, value: @value, &)
      end
    end

    private

    def css
      "button button--#{@variant}"
    end
  end
end
