class AddUserIdToBookings < ActiveRecord::Migration[7.0]
  def change
    # Step 1: Add user_id column without null constraint
    add_reference :bookings, :user, null: true, foreign_key: true
    
    # Step 2: Set user_id = 1 for old bookings
    Booking.reset_column_information
    Booking.update_all(user_id: 1)
    
    # Step 3: Now add the NOT NULL constraint
    change_column_null :bookings, :user_id, false
  end
end
