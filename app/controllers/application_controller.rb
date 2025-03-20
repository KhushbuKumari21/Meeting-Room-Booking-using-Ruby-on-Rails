class ApplicationController < ActionController::Base
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :check_admin, if: :admin_namespace?

  helper_method :user_signed_in?, :current_user

  private

  def devise_controller?
    is_a?(Devise::SessionsController) || is_a?(Devise::RegistrationsController) || is_a?(Devise::PasswordsController)
  end

  def check_admin
    if current_user && current_user.admin?
      return 
    end
    redirect_to root_path, alert: "Not authorized"
  end

  def admin_namespace?
    request.path.start_with?('/admin')
  end
end
