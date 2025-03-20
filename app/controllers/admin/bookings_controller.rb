class Admin::BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin

  def index
    @bookings = Booking.includes(:user, :meeting_room).order(:start_time)
  end
  private

  def authorize_admin
    Rails.logger.info "Current User Role: #{current_user.role}"
    redirect_to root_path, alert: 'Access denied!' unless current_user.admin?
  end
end
