class UrlValidator < ActiveModel::EachValidator

  def self.compliant?(value)
    uri = URI.parse(value)
    (uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)) && !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end

  def validate_each(record, attribute, value)
    unless value.present? && self.class.compliant?(value)
      record.errors.add(attribute, "is not a valid HTTP or HTTPS URL")
    end
  end
end

class Url < ApplicationRecord
  include ActiveModel::Validations
  attr_accessor :original

  validates :original, presence: true, uniqueness: true, url: true
end