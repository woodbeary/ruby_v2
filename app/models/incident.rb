class Incident < ApplicationRecord
  validates :title, presence: true
  validates :description, presence: true
  validates :priority, presence: true, inclusion: { in: %w[P1 P2 P3 P4 P5] }
  validates :status, presence: true, inclusion: { in: %w[open closed] }

  before_validation :set_default_status, on: :create

  private

  def set_default_status
    self.status ||= 'open'
  end
end
