class SessionsController < ApplicationController
  def create
    integration = current_user&.add_integration(auth_hash['provider'], auth_hash)
    redirect_to integration_path(integration)
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
