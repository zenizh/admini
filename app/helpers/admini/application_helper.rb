module Admini
  module ApplicationHelper
    include ActionView::Helpers::TranslationHelper
    include ActionView::Helpers::FormOptionsHelper
    include ActiveSupport::Multibyte::Unicode

    def enable_action?(action)
      routes.include?(controller: controller_path, action: action.to_s)
    end

    def search_options
      options = []
      search_attributes.each do |attribute|
        options << [t("activerecord.attributes.#{resource_name}.#{attribute}", default: attribute.to_s.camelize), attribute]
      end
      options_for_select(options)
    end

    private

    def routes
      @routes ||= Rails.application
        .routes
        .routes
        .map(&:defaults)
        .reject(&:blank?)
    end
  end
end
