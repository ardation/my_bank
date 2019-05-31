class IntegrationsController < ApplicationController
  decorates_assigned :integrations, :integration
  breadcrumb 'Integrations', :integrations_path

  def index
    load_integrations
    redirect_to integration_path(@integrations.first) if @integrations.count == 1
    redirect_to new_integration_path if @integrations.empty?
  end

  def show
    load_integration
    breadcrumb integration.service, :integration_path
    render("integrations/#{integration.service.underscore}/show")
  end

  def new
    if params[:service] && Integration::TYPES.keys.include?(params[:service])
      redirect_to auth_path(provider: params[:service].downcase)
    else
      active_types = integration_scope.pluck(:type)
      @types = Integration::TYPES.reject { |_k, v| active_types.include? v }
      breadcrumb 'New', new_integration_path
    end
  end

  def destroy
    load_integration
    @integration.destroy
    redirect_to integrations_path
  end

  protected

  def load_integrations
    @integrations ||= integration_scope.page params[:page]
  end

  def load_integration
    @integration ||= integration_scope.find(params[:integration_id] || params[:id])
  end

  def build_integration
    @integration ||= integration_scope.build
    @integration.attributes = integration_params
  end

  def save_integration
    redirect_to integration_path(@integration) if @integration.save
  end

  def integration_params
    integration_params = params[:integration]
    integration_params ? integration_params.permit(:username, :password, :type) : {}
  end

  def integration_scope
    current_user.integrations
  end
end
