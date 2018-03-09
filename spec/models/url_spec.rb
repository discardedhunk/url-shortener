require "rails_helper"

describe Url do
  describe '#original' do
    it 'should validate presence' do
      record = Url.new
      record.original = ''
      record.save
      expect(record.errors[:original]).to include("can't be blank")
    end

    it 'should validate http url' do
      record = Url.new
      record.original = 'htt'
      record.save
      expect(record.errors[:original]).to include("is not a valid HTTP or HTTPS URL")
    end
  end
end