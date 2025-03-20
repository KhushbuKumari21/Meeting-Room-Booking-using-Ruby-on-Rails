
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :bookings, dependent: :destroy

  validates :email, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }
  validates :role, presence: true

  enum :role, { employee: 0, admin: 1 }  

  after_initialize :set_default_role, if: :new_record?

  private

  def set_default_role
    self.role ||= :employee 
  end
end
