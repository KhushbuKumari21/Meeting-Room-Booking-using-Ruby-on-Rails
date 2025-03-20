class AddMeetingRoomIdToBookings < ActiveRecord::Migration[8.0]
  def change
    add_reference :bookings, :meeting_room, null: true, foreign_key: true
  end
end
