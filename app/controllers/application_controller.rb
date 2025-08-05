class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # For sign up
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :first_name, :last_name, :email, :password, :password_confirmation])

    # For account updates
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :first_name, :last_name, :avatar])
  end
end
