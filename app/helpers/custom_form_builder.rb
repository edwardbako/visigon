class CustomFormBuilder < ActionView::Helpers::FormBuilder
  def label(method, text = nil, options = {}, &block)
      str = "#{text ? text : object.class.human_attribute_name(method.to_s)} #{object.errors[method].join(', ')}"
      super(method, str, options.merge({class: ' form-label'}){|k, n, o| n + o}, &block)
  end

  def error_label(method, *args)
      if object.errors[method].any?
      label method, *args
      else
      '<br>'.html_safe if object.errors.any?
      end
  end

  [:text_field, :text_area, :email_field, :phone_field, :date_field, :datetime_field, :password_field, :number_field].each do |meth|
      define_method meth do |method, options = {}|
          super(method, merged_options(method, options))
      end
  end

  def check_box(method, options = {})
      super(method, options.merge({class: ' form-check-input'}){|k, n, o| n + o}) + ' ' + label(method, nil, class: 'form-check-label')
  end

  def select(method, choices = nil, options = {}, html_options = {}, &block) 
      super(
          method,
          choices,
          options,
          html_options.merge({class: ' form-select'}){|k, n, o| n + o},
          &block
      )
  end

  def merged_options(method, options)
      options.merge({class: " form-control #{validation_class(method)}"}){|k, n, o| n + o}
  end

  def validation_class(method)
      "is-invalid" if object.errors[method].any?
  end
end