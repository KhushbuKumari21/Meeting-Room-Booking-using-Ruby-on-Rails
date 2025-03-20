class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :meeting_room  

  STATUSES = ["pending", "confirmed", "canceled"].freeze

  validates :status, inclusion: { in: STATUSES, message: "must be pending, confirmed, or canceled" }
  validates :start_time, presence: true
  validates :end_time, presence: true

  validate :within_working_hours
  validate :validate_max_booking_hours
  validate :time_slot_must_be_half_hour
  validate :no_overlapping_bookings
  validate :end_time_after_start_time

  def confirmed?
    status == "confirmed"
  end

  def canceled?
    status == "canceled"
  end

  def status
    read_attribute(:status) || "pending"
  end

  private

  
  def within_working_hours
    if start_time.hour < 9 || end_time.hour > 18
      errors.add(:start_time, "must be within working hours (9 AM - 6 PM)")
    end
  end

  
  def validate_max_booking_hours
    total_booked_seconds = user.bookings.where("DATE(start_time) = ?", start_time.to_date)
                                        .sum("EXTRACT(EPOCH FROM (end_time - start_time))")

    booked_duration = (end_time - start_time).to_i

    if total_booked_seconds + booked_duration > 7200 
      errors.add(:base, "You can only book up to 2 hours per day.")
    end
  end

  
  def time_slot_must_be_half_hour
    unless start_time.min % 30 == 0 && end_time.min % 30 == 0
      errors.add(:start_time, "must be in 30-minute increments")
    end
  end

  
  def no_overlapping_bookings
    if time_slot_taken?(meeting_room, start_time, end_time)
      errors.add(:base, "This time slot is already booked. Please select a different time.")
    end
  end

  
  def end_time_after_start_time
    if end_time <= start_time
      errors.add(:end_time, "must be after the start time")
    end
  end

  
  def time_slot_taken?(meeting_room, start_time, end_time)
    meeting_room.bookings.where.not(id: id).where(
      "(start_time < ? AND end_time > ?) OR (start_time < ? AND end_time > ?)",
      end_time, start_time, start_time, end_time
    ).exists?
  end
end
