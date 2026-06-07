# The app-wide default form builder (config.action_view.default_form_builder), so
# `f.text_field` / `f.email_field` / `f.code_field` / `f.button` render our Phlex
# components — no per-call wiring. Each field method maps to a Field type and sets
# the sensible input-mode/autocomplete defaults for it.
class ApplicationFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options = {})
    field_component(:text, attribute, options)
  end

  def email_field(attribute, options = {})
    field_component(:email, attribute, {inputmode: "email", autocomplete: "email"}.merge(options))
  end

  def code_field(attribute, options = {})
    field_component(:code, attribute, {inputmode: "numeric", autocomplete: "one-time-code"}.merge(options))
  end

  def button(value = nil, options = {}, &block)
    component = Components::Button.new(
      type: :submit,
      variant: options.delete(:variant) || :primary,
      disabled: options.delete(:disabled) || false,
      data: options.delete(:data)
    )
    block ? @template.render(component, &block) : @template.render(component) { value }
  end

  private

  # Translate the bound object/attribute into the field's concrete name + id.
  def field_component(type, attribute, options)
    @template.render Components::Field.new(name: field_name(attribute), id: field_id(attribute), type:, options:)
  end
end
