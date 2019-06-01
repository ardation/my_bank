class ApplicationController < ActionController::Base
  layout :layout_by_resource
  protect_from_forgery prepend: true
  breadcrumb 'Home', :root

  private

  def layout_by_resource
    devise_controller? ? 'devise' : 'application'
  end
end
