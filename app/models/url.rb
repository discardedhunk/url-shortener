class UrlValidator < ActiveModel::EachValidator
  HOSTNAME_REGEX = /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}$/x

  def self.compliant?(value)
    uri = URI.parse(value).normalize
    (uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)) && !uri.hostname.nil? && !(uri.hostname =~ HOSTNAME_REGEX).nil?
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

  validates :original, presence: true, uniqueness: true, url: true
  validates :shortened, uniqueness: true

  before_create do
    self.original = URI.parse(self.original).normalize
    self.shorten
  end

  CHARS = (('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a - ['0', 'O', 'I', 'l']).join
  BASE = CHARS.length

  SHORTENED_LENGTH = 8

  # bijective functions are here to show a more basic approach to shorten a URL
  def bijective_encode(id)
    code = ''

    while id > 0
      code << CHARS[id.modulo(BASE)]
      id /= BASE
    end

    code.reverse
  end

  def bijective_decode(s)
    id = 0
    base = CHARS.length

    s.each_char do |char|
      id = id * base + CHARS.index(char)
    end

    id
  end

  def shorten
    self.shortened = SecureRandom.base58(SHORTENED_LENGTH)
  end

  def self.get_by_shortened(code)
    return nil if (code =~ /\w{#{SHORTENED_LENGTH}}/).nil?

    Url.find_by_shortened(code)
  end
end