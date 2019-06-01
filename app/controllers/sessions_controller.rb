class SessionsController < ApplicationController
  before_action :authenticate_user!

  def create
    integration = current_user&.add_integration(auth_hash['provider'], auth_hash)
    redirect_to integration_path(integration)
    flash[:success] = 'Integration added successfully. Please allow 10 minutes for My Bank to sync your data.'
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
