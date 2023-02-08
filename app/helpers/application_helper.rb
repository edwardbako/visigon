module ApplicationHelper

  def flash_class(name)
    "alert-#{flash_mapping[name]}"
  end

  def flash_mapping
    map = Hash.new(:info)
    map.merge( {
      notice: :success,
      alert: :warning,
      error: :danger
    }).with_indifferent_access
  end

end
