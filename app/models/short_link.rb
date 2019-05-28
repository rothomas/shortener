class ShortLink < ApplicationRecord
  validates :long_url, presence: true
  validates :short_code, presence: true, uniqueness: true
  validates :user_id, presence: true
  validates_uniqueness_of :long_url, scope: [:user_id]

  has_many :redirect_records

  def self.find_for_request(short_code, request, is_analytics)
    link = find_by_short_code(short_code)
    unless link.nil? or is_analytics
      link.redirect_records.create!(referrer: request.env['HTTP_REFERRER'], user_agent: request.env['HTTP_USER_AGENT'])
    end
    link
  end

  def to_analytics
    {
        response: redirect_records.map do |record|
          {
              time: record.created_at.iso8601,
              referrer: record.referrer || 'none',
              user_agent: record.user_agent || 'none'
          }
        end
    }
  end

end
