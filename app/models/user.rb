class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :alert_end_date, comparison: { greater_than_or_equal_to: :alert_start_date },
            if: -> { alert_start_date.present? && alert_end_date.present? }

  scope :with_active_alerts_for, ->(date) {
    where("alert_start_date <= ? AND alert_end_date >= ?", date, date)
  }
  scope :email_enabled, -> { where(email_enabled: true) }

  def admin?
    admin
  end
end
