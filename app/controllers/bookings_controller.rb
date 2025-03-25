class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_employee, only: [:create]
  before_action :set_meeting_room, only: [:new, :create]
  before_action :set_booking, only: [:show, :destroy, :cancel_booking]

  def index
    @bookings = Booking.includes(:meeting_room).where(user_id: current_user.id)
  end

  def show
  end

  def new
    @meeting_room = MeetingRoom.find_by(id: params[:meeting_room_id])
    if @meeting_room.nil?
      flash[:alert] = "Meeting Room not found. Please select a valid room."
      redirect_to meeting_rooms_path and return
    end
    @booking = Booking.new(meeting_room: @meeting_room)
  end

  def create
    @booking = current_user.bookings.new(booking_params)
    @meeting_room = MeetingRoom.find_by(id: params[:meeting_room_id])
    return redirect_to meeting_rooms_path, alert: "Invalid meeting room selected." unless @meeting_room

    start_time = parse_datetime(params[:booking], "start_time")
    end_time = parse_datetime(params[:booking], "end_time")

    return redirect_to new_meeting_room_booking_path(@meeting_room), alert: "Invalid date/time format." unless start_time && end_time
    return redirect_to new_meeting_room_booking_path(@meeting_room), alert: "Invalid time slot. Select half-hour intervals." unless valid_time_slot?(start_time, end_time)
    return redirect_to new_meeting_room_booking_path(@meeting_room), alert: "You have exceeded your daily booking limit of 2 hours." if exceeds_daily_limit?(current_user, start_time, end_time)
    return redirect_to new_meeting_room_booking_path(@meeting_room), alert: "Time slot is already booked. Choose another time." if time_slot_taken?(@meeting_room, start_time, end_time)

    @booking.assign_attributes(start_time: start_time, end_time: end_time, meeting_room: @meeting_room)

    if @booking.save
      redirect_to bookings_path, notice: "Booking successful."
    else
      flash[:alert] = "Booking failed. Please try again."
      render :new
    end
  end

  def destroy
    @booking = current_user.bookings.find(params[:id])
    return redirect_to bookings_path, alert: "You can only cancel before the selected time period." if Time.current > @booking.start_time - 30.minutes
    return redirect_to bookings_path, alert: "Cannot cancel past bookings." unless @booking.start_time >= Time.current
    @booking.destroy
    redirect_to bookings_path, notice: "Booking cancelled successfully."
  end

  

  def cancel_booking
    if @booking.start_time < Time.current
      redirect_to bookings_path, alert: "You cannot cancel past bookings." and return
    end
  
    if @booking.update(status: "cancelled")
      redirect_to bookings_path, notice: "Booking was successfully cancelled."
    else
      redirect_to bookings_path, alert: "Failed to cancel booking."
    end
  end


  private

  def ensure_employee
    return unless current_user.admin?
    flash[:alert] = "Admins cannot book meeting rooms!"
    redirect_to meeting_rooms_path
  end

  def set_meeting_room
    @meeting_room = MeetingRoom.find_by(id: params[:meeting_room_id])
    return if @meeting_room
    flash[:alert] = "Meeting Room not found"
    redirect_to bookings_path and return
  end

  def set_booking
    @booking = Booking.find_by(id: params[:id], user_id: current_user.id)
    return if @booking
    flash[:alert] = "Booking not found"
    redirect_to bookings_path
  end

  def parse_datetime(params, key)
    DateTime.new(
      params["#{key}(1i)"].to_i,
      params["#{key}(2i)"].to_i,
      params["#{key}(3i)"].to_i,
      params["#{key}(4i)"].to_i,
      params["#{key}(5i)"].to_i
    ) rescue nil
  end

  def valid_time_slot?(start_time, end_time)
  return false unless [0, 30].include?(start_time.min) && [0, 30].include?(end_time.min)
  return false unless end_time > start_time
  return false unless (end_time - start_time) % 30.minutes == 0
  true
end


  def exceeds_daily_limit?(user, start_time, end_time)
    total_booked_time = Booking.where(user_id: user.id)
                               .where("DATE(start_time) = ?", start_time.to_date)
                               .sum("EXTRACT(EPOCH FROM (end_time - start_time)) / 3600.0")
    new_booking_hours = (end_time - start_time) / 3600.0
    (total_booked_time + new_booking_hours) > 2
  end

  def time_slot_taken?(meeting_room, start_time, end_time)
    meeting_room.bookings.where(
      "(start_time < ? AND end_time > ?) OR (start_time >= ? AND start_time < ?) OR (end_time > ? AND end_time <= ?)",
      end_time, start_time, start_time, end_time, start_time, end_time
    ).exists?
  end

  def booking_params
    params.require(:booking).permit(:start_time, :end_time, :meeting_room_id)
  end
end
