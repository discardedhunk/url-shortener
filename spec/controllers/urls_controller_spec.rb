require 'rails_helper'

describe UrlsController do

  describe 'GET index' do

    it 'assigns @urls' do
      Url.create
      get :index
      expect(assigns(:urls)).to eq(Url.all)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET new' do

    it 'assigns @url' do
      url = Url.new
      allow(Url).to receive(:new).and_return(url)
      get :new
      expect(assigns(:url)).to eq(url)
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template('new')
    end
  end

  describe 'create' do

    before(:each) do
      @url = Url.new(original: 'https://google.com')
      allow(Url).to receive(:new).and_return(@url)
    end

    it 'calls Url.new' do
      allow(@url).to receive(:save!)
      post :create, params: {url: {original: 'https://google.com'}}

      expect(Url).to have_received(:new).with({original: 'https://google.com'})
    end

    it 'redirects to show' do
      allow(@url).to receive(:save!).and_return(true)

      post :create, params: {url: {original: 'https://google.com'}}
      expect(response).to redirect_to(@url)
    end

    it 'sets flash notice message' do
      allow(@url).to receive(:save!).and_return(true)

      post :create, params: {url: {original: 'https://google.com'}}
      expect(flash[:notice]).to eql('URL has been shortened!')
    end

    describe 'error cases' do
      it 'calls Url#shortened if there is a collision in the shortened code' do
        @counter = 0
        allow(@url).to receive(:save!) do
          @counter += 1
          raise ActiveRecord::RecordNotUnique.new('index_urls_on_shortened') if @counter < 2
          true
        end
        allow(@url).to receive(:shorten)

        post :create, params: {url: {original: 'https://google.com'}}
        expect(@url).to have_received(:shorten)
      end

      it 'flash error message if original url is already shortened' do
        allow(@url).to receive(:save!).and_raise(ActiveRecord::RecordNotUnique, 'index_urls_on_original')

        post :create, params: {url: {original: 'https://google.com'}}
        expect(flash[:error]).to eql('Url https://google.com has already been shortened.')
      end

      it 'sets flash error message to validation error message' do
        allow(@url).to receive(:save!).and_return(false)
        errors = double('errors')
        allow(@url).to receive(:errors).and_return(errors)
        allow(errors).to receive(:full_messages).and_return(['bad url'])
        post :create, params: {url: {original: 'https://google.com'}}

        expect(flash[:error]).to eql('bad url')
      end
    end
  end

  describe 'GET show' do

    before(:each) do
      @url = Url.new(id: 1)
      allow(Url).to receive(:find).and_return(@url)
      get :show, params: {id: @url.id}
    end

    it 'assigns @url' do
      expect(assigns(:url)).to eq(@url)
    end

    it 'renders the show template' do
      expect(response).to render_template('show')
    end
  end

  describe 'GET shortened' do

    it 'calls Url.get_by_shortened with the shortened param' do
      allow(Url).to receive(:get_by_shortened)
      shortened = "foo"
      get :shortened, params: {shortened: shortened}
      expect(Url).to have_received(:get_by_shortened)
    end

    it 'redirects to the original URL if found' do
      url = Url.new(original: 'https://google.com/', shortened: '8zndKjGR')
      allow(Url).to receive(:get_by_shortened).and_return(url)
      get :shortened, params: {shortened: url.shortened}
      expect(response).to redirect_to(url.original)
    end

    it 'set flash error if not found' do
      allow(Url).to receive(:get_by_shortened).and_return(nil)
      get :shortened, params: {shortened: 'bad'}
      expect(flash[:error]).to eql('Sorry, that code was not found. Please shorten a new URL.')
    end

    it 'redirects new action if not found' do
      allow(Url).to receive(:get_by_shortened).and_return(nil)
      get :shortened, params: {shortened: 'bad'}
      expect(response).to redirect_to(new_url_url)
    end
  end

  describe 'DELETE destroy' do

    before(:each) do
      @url = double('Url')
      allow(@url).to receive(:destroy)
      allow(Url).to receive(:find).and_return(@url)

      delete :destroy, params: {id: 1}
    end

    it 'calls #destroy on the found url' do
      expect(@url).to have_received(:destroy)
    end

    it 'redirects to index' do
      expect(response).to redirect_to(urls_url)
    end

    it 'redirects to index if url is not found' do
      allow(Url).to receive(:find).and_return(nil)

      delete :destroy, params: {id: 1}
      expect(response).to redirect_to(urls_url)
    end
  end
end