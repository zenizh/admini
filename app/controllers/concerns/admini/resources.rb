module Admini
  class AuthorizationError < StandardError; end

  module Resources
    extend ActiveSupport::Concern

    included do
      before_action :load_resources, only: :index
      before_action :load_resource, only: [:edit, :update, :show, :destroy]
      before_action :build_resource, only: [:new, :create]
      before_action :search_resources, only: :index
      before_action :authorize

      helper_method :index_attributes,
        :new_attributes,
        :create_attributes,
        :edit_attributes,
        :update_attributes,
        :show_attributes,
        :search_attributes,
        :enum_attributes,
        :can_create?,
        :can_read?,
        :can_update?,
        :can_delete?,
        :render_attribute,
        :resource_name,
        :resource_object

      layout 'admini/layouts/application'
    end

    def index
      @resources = @resources.order(id: :desc)
        .page(params[:page])
        .per(paginates_per)
    end

    def new
    end

    def create
      if @resource.save
        redirect_to action: :show, id: @resource.id
      else
        render :new
      end
    end

    def show
    end

    def edit
    end

    def update
      if @resource.update(resource_params)
        redirect_to action: :show, id: @resource.id
      else
        render :edit
      end
    end

    def destroy
      @resource.destroy
      redirect_to action: :index
    end

    private

    def resource_class
      @resource_class ||= controller_name.classify.constantize
    end

    def resource_name
      @resource_name ||= resource_class.to_s.downcase
    end

    def resources
      @resources ||= resource_class.all
    end
    alias_method :load_resources, :resources

    def resource
      @resource ||= resource_class.find(params[:id])
    end
    alias_method :load_resource, :resource

    def build_resource
      @resource = case action_name
                  when 'new'
                    resource_class.new
                  when 'create'
                    resource_class.new(resource_params)
                  end
    end

    def resource_params
      params.require(resource_name).permit(send("#{action_name}_attributes"))
    end

    def search_resources
      unless search_attributes.include?(params[:attribute].try(:to_sym))
        return
      end
      @resources = @resources.where("#{params[:attribute]} LIKE ?", "%#{params[:value]}%")
    end

    def index_attributes
      %i(id created_at updated_at)
    end

    def show_attributes
      index_attributes
    end

    def new_attributes
      %i()
    end

    def create_attributes
      new_attributes
    end

    def edit_attributes
      new_attributes
    end

    def update_attributes
      edit_attributes
    end

    def search_attributes
      %i()
    end

    def enum_attributes
      %i()
    end

    def authorize
      unless send("can_#{crud_type}?")
        authorization_error
      end
    end

    def crud_type
      case action_name
      when 'new', 'create'
        :create
      when 'index', 'show'
        :read
      when 'edit', 'update'
        :update
      when 'destroy'
        :delete
      end
    end

    def can_create?
      true
    end

    def can_read?
      true
    end

    def can_update?
      true
    end

    def can_delete?
      true
    end

    def authorization_error
      if defined?(super)
        super
      else
        raise Admini::AuthorizationError
      end
    end

    def resource_object
      defined?(super) ? super : [:admin, resource]
    end

    def render_attribute(resource, attribute)
      if self.class.private_method_defined?("render_#{attribute}")
        send("render_#{attribute}", resource)
      else
        resource.send(attribute)
      end
    end

    def paginates_per
      defined?(super) ? super : 25
    end

    def _prefixes
      super << 'admini/resources'
    end
  end
end
