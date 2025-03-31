
class MeetingRoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_meeting_room, only: [:available_slots]

  def index
    @meeting_rooms = MeetingRoom.all
  end
  
  def show
    @meeting_room = MeetingRoom.find(params[:id])
  end

  def available_slots
    booked_slots = @meeting_room.bookings.pluck(:start_time, :end_time)
    all_slots = generate_half_hour_slots

    available_slots = all_slots.reject do |slot|
      booked_slots.any? { |b| slot.between?(b[0], b[1]) }
    end

    render json: { available_slots: available_slots }
  end
  private

  def set_meeting_room
    @meeting_room = MeetingRoom.find(params[:id])
  end
def generate_half_hour_slots
  start_of_day = Time.zone.now.beginning_of_day + 9.hours 
  end_of_day = start_of_day + 9.hours 

  slots = []
  current_time = start_of_day
  while current_time < end_of_day
    slots << current_time
    current_time += 30.minutes
  end
  slots
end
end
