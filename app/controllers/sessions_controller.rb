class SessionsController < ApplicationController
  before_action :authenticate_user!

  def create
    integration = current_user&.add_integration(auth_hash['provider'], auth_hash)
    redirect_to integration_path(integration)
    flash[:success] = 'Integration added successfully. Sync will begin shortly.'
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
