module ParamsWrapper
  def wrapped_params(params = {})
    if Rails.gem_version >= Gem::Version.new('5.0.0')
      { params: params }
    else
      params
    end
  end
end
