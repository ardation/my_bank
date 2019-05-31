class ApplicationController < ActionController::Base
  before_action :authenticate_user!, unless: :devise_controller?
  protect_from_forgery prepend: true
  breadcrumb 'Home', :root

  def index
    redirect_to banks_path
  end
end
