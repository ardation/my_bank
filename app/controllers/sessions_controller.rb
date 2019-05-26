class SessionsController < ApplicationController
  def create
    current_user&.add_integration(auth_hash['provider'], auth_hash)
    redirect_to '/'
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
