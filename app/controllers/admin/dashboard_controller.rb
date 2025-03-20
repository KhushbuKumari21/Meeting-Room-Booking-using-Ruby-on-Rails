module Admin
    class DashboardController < ApplicationController
      before_action :ensure_admin
  
      def index
        @bookings = Booking.includes(:meeting_room, :user)
        @meeting_rooms = MeetingRoom.all
        filter_bookings
  
        @total_booked_slots = @bookings.count
      end
  
      def new
        @meeting_room = MeetingRoom.new
      end
  
      def create
        @meeting_room = MeetingRoom.new(meeting_room_params)
        if @meeting_room.save
          flash[:notice] = "Meeting room successfully added."
          redirect_to admin_dashboard_path
        else
          flash[:alert] = "Error adding meeting room."
          render :new
        end
      end
  
      private
  
      def filter_bookings
        @bookings = @bookings.where("DATE(start_time) = ?", params[:date]) if valid_date?(params[:date])
        @bookings = @bookings.joins(:meeting_room).where("meeting_rooms.name ILIKE ?", "%#{params[:room]}%") if params[:room].present?
        @bookings = @bookings.joins(:user).where("users.name ILIKE ?", "%#{params[:user]}%") if params[:user].present?
        @bookings = filter_time_slot(@bookings, params[:time_slot]) if params[:time_slot].present?
        @bookings = filter_by_amenities(@bookings, params[:amenities]) if params[:amenities].present?
        @bookings = filter_available_slots(@bookings) if params[:available_slots].present?
      end
  
      def filter_time_slot(bookings, time_slot)
        start_time = DateTime.parse(time_slot) rescue nil
        return bookings unless start_time
  
        end_time = start_time + 30.minutes
        bookings.where("start_time >= ? AND end_time <= ?", start_time, end_time)
      end
  
      def filter_by_amenities(bookings, amenities)
        amenities_list = amenities.split(",").map(&:strip) 
        bookings.joins(:meeting_room).where("meeting_rooms.amenities @> ARRAY[?]::varchar[]", amenities_list)
      end
  
      def filter_available_slots(bookings)
        all_meeting_rooms = MeetingRoom.all.pluck(:id)
        booked_rooms = bookings.pluck(:meeting_room_id)
        available_rooms = all_meeting_rooms - booked_rooms
        bookings.where(meeting_room_id: available_rooms)
      end
  
      def valid_date?(date_string)
        Date.parse(date_string) rescue false
      end
      def ensure_admin
        if current_user.nil?
          flash[:alert] = "You must be signed in."
          redirect_to new_user_session_path
        elsif !current_user.admin?
          flash[:alert] = "Access denied. Admins only."
          redirect_to root_path
        end
      end
      def meeting_room_params
        params.require(:meeting_room).permit(:name, :capacity, :amenities)
      end
    end
  end
  