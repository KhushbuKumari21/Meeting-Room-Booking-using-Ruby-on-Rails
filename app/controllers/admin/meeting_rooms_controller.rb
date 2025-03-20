class Admin::MeetingRoomsController < ApplicationController
    
  before_action :authenticate_user!
  before_action :authorize_admin!, only: [:index, :new, :create, :edit, :update, :destroy]
  
  before_action :set_meeting_room, only: [:edit, :update, :show, :destroy]
 


  def index
    @meeting_rooms = MeetingRoom.all 
    Rails.logger.debug "Meeting Rooms: #{@meeting_rooms.inspect}"
  end
  
  def show
    @meeting_room = MeetingRoom.find(params[:id])
  end

  def new
    @meeting_room = MeetingRoom.new
  end

  def create
    @meeting_room = MeetingRoom.new(meeting_room_params)
    if @meeting_room.save
      redirect_to admin_meeting_rooms_path, notice: "Meeting room added successfully!"
    else
      render :new
    end
  end

  def edit
    @meeting_room = MeetingRoom.find(params[:id])
  end

  def update
    @meeting_room = MeetingRoom.find(params[:id])
    if @meeting_room.update(meeting_room_params)
      redirect_to admin_meeting_rooms_path, notice: "Meeting room updated successfully!"
    else
      render :edit
    end
  end
  def destroy
    @meeting_room.destroy
    respond_to do |format|
      format.html { redirect_to admin_meeting_rooms_path, notice: "Meeting room was successfully deleted." }
      format.json { head :no_content }
    end
  end
  
  private
  def set_booking
    @booking = Booking.find(params[:id])
  end
  def meeting_room_params
    params.require(:meeting_room).permit(:name, :capacity)
  end

  def authorize_admin!
    redirect_to root_path, alert: 'Access denied!' unless current_user.admin?
  end
end
def set_meeting_room
  @meeting_room = MeetingRoom.find(params[:id])
end
