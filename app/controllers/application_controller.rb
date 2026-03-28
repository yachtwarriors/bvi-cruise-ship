class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Not authorized."
    end
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(User) && resource.admin?
      manage_root_path
    else
      root_path
    end
  end
end
