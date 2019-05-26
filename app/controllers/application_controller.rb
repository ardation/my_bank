class ApplicationController < ActionController::Base
  before_action :authenticate_user!, unless: :devise_controller?
  protect_from_forgery prepend: true
  breadcrumb 'Home', :root
end
