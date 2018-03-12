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
      @original = 'https://google.com'
      @url = Url.new(original: @original, id: 1)
      allow(Url).to receive(:new_url).and_return(@url)
      allow(@url).to receive(:persisted?).and_return(true)
      post :create, params: {url: {original: @original}}
    end

    it 'calls Url.new_url' do
      expect(Url).to have_received(:new_url).with(@original)
    end

    it 'redirects to show' do
      expect(response).to redirect_to(@url)
    end

    it 'sets flash notice message' do
      expect(flash[:notice]).to eql('URL has been shortened!')
    end

    describe 'error cases' do

      before(:each) do
        allow(@url).to receive(:persisted?).and_return(false)
        @message = 'Original already taken'
        allow(@url).to receive_message_chain(:errors, :full_messages => [@message])

        post :create, params: {url: {original: 'https://google.com'}}
      end

      it 'sets flash error message to validation error message' do
        expect(flash[:error]).to eql(@message)
      end

      it 'renders new action' do
        expect(response).to render_template('new')
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