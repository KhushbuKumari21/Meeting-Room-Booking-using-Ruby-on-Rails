class CreateMeetingRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :meeting_rooms do |t|
      t.string :name
      t.integer :capacity

      t.timestamps
    end
  end
end
