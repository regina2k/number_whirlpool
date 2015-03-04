class CityEvent < ActiveRecord::Base
  has_many :event_times, :dependent => :destroy, autosave: true
  has_and_belongs_to_many :places, join_table: :events_places
  has_and_belongs_to_many :tags, join_table: :events_tags

  has_many :source_links, as: :sourceable, autosave: true, dependent: :destroy
  has_many :user_choices, dependent: :destroy

  include Dictionary
  include WithImageLinks

  accepts_nested_attributes_for :places

  PARTY = 5018
  CONCERT = 5019
  EXPOSITION = 5021
  SPECTACLE = 5020
  FILM = 5022

  has_dictionary :event_type, [ ['Вечеринка', PARTY], ['Спектакль', SPECTACLE], ['Концерт (шоу)', CONCERT], ['Выставка', EXPOSITION], ['Кино', FILM] ]


  scope :between_times, -> (date_from, date_to) {
    includes(:event_times).references(:event_times).where('event_times.time <= ? AND event_times.time >= ?',
                                                          date_to, date_from)
  }

  scope :since_time, -> (date) { includes(:event_times).references(:event_times).where('event_times.time >= ?', date) }
  scope :since_from, -> (date) { includes(:event_times).references(:event_times).where('event_times.time <= ?', date) }

  scope :by_type, -> (type_id) { where('event_type_id IN (?)', type_id) }

  scope :in_city, -> (city_id) { joins(:places).where('places.city_id = ?', city_id).uniq }

  scope :by_tags, -> (tags_ids) { joins(:tags).where('tag_id IN (?)', tags_ids).uniq }

  scope :actived, -> (published) { where('published = ?', published) }

  default_scope { order 'city_events.created_at desc' }

  scope :no_tags, -> {
                    joins("LEFT JOIN events_tags ON city_events.id = events_tags.city_event_id").
                        where("events_tags.tag_id IS NULL").uniq
                }

  scope :has_tags, -> (tag_ids) {
    joins("LEFT JOIN events_tags ON city_events.id = events_tags.city_event_id").
        where("events_tags.tag_id IN (?)", tag_ids).uniq
  }

  validates :name, :presence => true
  validates :event_type_id, :presence => true

  def self.in_current_city
    if City.current.present?
      CityEvent.in_city(City.current.id)
    else
      CityEvent.all
    end
  end


  def self.with_tag(tag_id)
    if tag_id == 0
      no_tags
    else
      has_tags(tag_id)
    end
  end
end