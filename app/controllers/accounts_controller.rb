class AccountsController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def update
    @user = current_user

    if params[:clear_dates]
      @user.update!(alert_start_date: nil, alert_end_date: nil)
      redirect_to account_path, notice: "Alert dates removed."
    elsif @user.update(account_params)
      redirect_to account_path, notice: "Alert dates updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:user).permit(:alert_start_date, :alert_end_date)
  end
end
