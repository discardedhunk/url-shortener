require 'rails_helper'
require 'capybara/rspec'

describe 'Url Shortener App', :type => :feature do
  before :each do
    @url = Url.create(original: 'https://google.com')
  end

  describe 'list view' do

    before :each do
      visit '/'
    end

    describe 'Header' do

      it 'has the correct content' do
        expect(page).to have_content 'Jason LaCarrubba\'s URL Shortener'
      end

      it 'has new link' do
        expect(page).to have_link 'New', href: '/urls/new'
      end

      it 'has List link' do
        expect(page).to have_link 'List', href: '/urls'
      end
    end

    describe 'content' do

      it 'has heading' do
        expect(page).to have_content 'Shortened URLs'
      end

      it 'has the original URL' do
        expect(page).to have_content @url.original
      end

      it 'has the shortened link' do
        expect(page).to have_link @url.shortened, href: "#{current_url}#{@url.shortened}"
      end

      it 'has show link' do
        expect(page).to have_link 'Show', href: "/urls/#{@url.id}"
      end

      it 'has delete link' do
        expect(page).to have_link 'Delete', href: "/urls/#{@url.id}"
      end

      describe 'show link' do

        it 'renders show page' do
          page.find(:link, text: 'Show').click
          expect(page).to have_content 'Entry Detail'
        end
      end
    end
  end

  describe 'show view' do

    before :each do
      visit "/urls/#{@url.id}"
    end

    describe 'content' do

      it 'has heading' do
        expect(page).to have_content 'Entry Detail'
      end

      it 'has original url' do
        expect(page).to have_content "Original: #{@url.original}"
      end

      it 'has shortened' do
        expect(page).to have_content "Shortened: #{@url.shortened}"
      end

      it 'has shortened link' do
        host = URI.parse(current_url).hostname
        expect(page).to have_link @url.shortened, href: "http://#{host}/#{@url.shortened}"
      end
    end
  end

  describe 'new view' do

    before :each do
      visit '/urls/new'
    end

    describe 'content' do
      it 'has heading' do
        expect(page).to have_content 'Shorten A New URL'
      end
    end

    describe 'form submission' do

      it 'does' do
        fill_in 'url_original', with: 'https://amazon.com'
        click_button 'Submit'

        expect(page).to have_content 'URL has been shortened!'
      end
    end
  end

  describe 'redirect' do

    before :each do
      visit '/'
      page.find(:link, href: "#{current_url}#{@url.shortened}").click
    end

    it 'redirects to the original url' do
      expect(current_url).to eql(@url.original)
    end
  end
end