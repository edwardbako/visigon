ActionView::Base.field_error_proc = lambda do |html_tag, instance|
  html_tag
end