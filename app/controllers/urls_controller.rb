class UrlsController < ApplicationController
  def index
    @urls = Url.all

    respond_to do |format|
      format.html
    end
  end

  def new
    @url = Url.new

    respond_to do |format|
      format.html
    end
  end

  def show
    @url = Url.find(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def shortened
    @url = Url.get_by_shortened(params[:shortened])

    if @url
      redirect_to @url.original, status: :moved_permanently
    else
      flash[:error] = 'Sorry, that code was not found. Please shorten a new URL.'
      redirect_to action: 'new'
    end
  end

  def create
    saved = false
    url_taken = nil
    begin
      @url = Url.new(original: params[:url][:original])
      saved = @url.save!
    rescue ActiveRecord::RecordNotUnique => e
      # check if we have a collision in the shortened and retry
      if e.message.include?('index_urls_on_shortened')
        @url.shorten
        saved = @url.save!
      else
        # workaround for @url.errors.full_messages[0] not always getting set
        url_taken = "Url #{@url.original} has already been shortened."
      end
    rescue ActiveRecord::RecordInvalid => e
      logger.error e.message
    end

    if saved
      flash[:notice] = 'URL has been shortened!'
      redirect_to @url
    else
      respond_to do |format|
        flash.now[:error] = url_taken ? url_taken : @url.errors.full_messages[0]
        format.html { render action: 'new' }
      end
    end
  end

  def destroy
    url = Url.find(params[:id])
    url.destroy if url

    redirect_to urls_url
  end
end