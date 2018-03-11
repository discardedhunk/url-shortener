require "rails_helper"

describe Url do
  describe '#original' do

    it 'validates presence' do
      record = Url.new(original: '')
      record.valid?
      expect(record.errors[:original]).to include("can't be blank")
    end

    it 'validates http(s) url with invalid protocol' do
      record = Url.new(original: 'htt')
      record.valid?
      expect(record.errors[:original]).to include("is not a valid HTTP or HTTPS URL")
    end

    it 'validates http(s) url with missing hostname' do
      record = Url.new(original: 'http://')
      record.valid?
      expect(record.errors[:original]).to include("is not a valid HTTP or HTTPS URL")
    end

    it 'validates http url with no path' do
      record = Url.new(original: 'http://google.com')
      record.valid?
      expect(record).to be_valid
    end

    it 'validates https url with no path' do
      record = Url.new
      record.original = 'https://google.com'
      record.valid?
      expect(record).to be_valid
    end

    it 'validates url with path and query string' do
      record = Url.new(original: 'https://google.com/maps/foo/?parm=123')
      record.valid?
      expect(record).to be_valid
    end

    it 'validates uniqueness' do
      rec1 = Url.create!(original: 'https://google.com')
      rec2 = Url.new(original: rec1.original)
      rec2.valid?
      expect(rec2.errors[:original]).to include 'has already been taken'
    end

    it 'validates whilespace is not allowed' do
      record = Url.new(original: 'https://goo gle.com/maps/foo/?parm=123')
      record.valid?
      expect(record).to_not be_valid
    end

    it 'validates unusual characters not allowed' do
      record = Url.new(original: 'https://google.com/maps/{var}')
      record.valid?
      expect(record).to_not be_valid
    end

    it 'validates missing hostname is not allowed' do
      record = Url.new(original: 'https://')
      record.valid?
      expect(record).to_not be_valid
    end

    it 'validates missing top level domain is not allowed' do
      record = Url.new(original: 'https://f')
      record.valid?
      expect(record).to_not be_valid
    end

    it 'validates subdomain is allowed' do
      record = Url.new(original: 'https://docs.google.com')
      record.valid?
      expect(record).to be_valid
    end

    it 'validates second-level domain is allowed' do
      record = Url.new(original: 'https://docs.google.co.uk')
      record.valid?
      expect(record).to be_valid
    end

    it 'lowers case of hostname' do
      hostname = 'Google.com'
      record = Url.create!(original: "https://#{hostname}/")
      expect(record.original).to eql("https://#{hostname.downcase}/")
    end

    it 'adds trailing slash when absent' do
      hostname = 'google.com'
      record = Url.create!(original: "https://#{hostname}")
      expect(record.original).to eql("https://#{hostname}/")
    end
  end

  describe '#bijective_encode' do
    it 'returns a code for the given ID' do
      expect(Url.new.bijective_encode(100)).to eql('bT')
    end
  end

  describe '#bijective_decode' do
    it 'returns a code for the given ID' do
      expect(Url.new.bijective_decode('bT')).to eql(100)
    end
  end

  describe '#shorten' do
    it 'calls SecureRandom.base58 with the desired length' do
      allow(SecureRandom).to receive(:base58).and_return('random')
      Url.new(original: 'https://foo.com').save
      expect(SecureRandom).to have_received(:base58).with(8)
    end

    it 'sets shortened attribute to the return of SecureRandom.base58()' do
      allow(SecureRandom).to receive(:base58).and_return('random')
      rec = Url.new(original: 'https://foo.com')
      rec.save
      expect(rec.shortened).to eql('random')
    end

    it 'does not allow duplicates' do
      allow(SecureRandom).to receive(:base58).and_return('random')
      Url.create!(original: 'https://foo.com')
      rec = Url.new(original: 'https://bar.com')
      rec.shorten
      rec.valid?
      expect(rec.errors[:shortened]).to include 'has already been taken'
    end
  end

  describe '.get_by_shortened' do
    it 'returns nil if code is not valid' do
      expect(Url.get_by_shortened("foo")).to eql(nil)
    end

    it 'calls Url.find_by_shortened if code is valid' do
      code = "8zndKjGR"
      allow(Url).to receive(:find_by_shortened)
      Url.get_by_shortened(code)
      expect(Url).to have_received(:find_by_shortened).with(code)
    end

    it 'returns the found URL' do
      url = Url.new
      allow(Url).to receive(:find_by_shortened).and_return(url)
      expect(Url.get_by_shortened("8zndKjGR")).to eql(url)
    end
  end
end