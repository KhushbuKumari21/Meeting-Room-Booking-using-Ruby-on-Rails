class AddAvailableToMeetingRooms < ActiveRecord::Migration[8.0]
  def change
    add_column :meeting_rooms, :available, :boolean
  end
end
