# == Schema Information
#
# Table name: contests
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  start_date  :datetime
#  end_date    :datetime
#  active      :boolean          default(TRUE)
#

class Contest < ActiveRecord::Base
  attr_accessible :name, :description, :start_date, :end_date, :active

  has_many :contest_albums

  #default_scope :order => :created_at
  scope :performing, -> { where("start_date <= ? AND end_date >= ? AND active = 1", Time.now, Time.now).order("end_date DESC") }
  scope :non_performing, -> { where("end_date <= ? OR active = 0", Time.now).order("end_date DESC") }

  validate :contest_dates_should_be_valid


  def latest_members limit_num
    contest_albums.order('created_at DESC').limit limit_num
  end


  def best_members limit_num
    contest_albums.reorder('rating DESC').limit limit_num
  end


  def active?
    start_date <= Time.now && end_date >= Time.now && active
  end


  def self.last_past
    Contest.non_performing.first
  end


  def self.performing?
    performing.exists?
  end


  def user_participate? user
    user.present? && user.contest_albums.where(contest_id: id).exists?
  end


  private


  def contest_dates_should_be_valid
    errors.add(:start_date, "Дата начала больше даты окончания") unless start_date < end_date
  end
end
