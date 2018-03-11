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

    respond_to do |format|
      if saved
        flash.now[:notice] = 'URL has been shortened!'
        format.html { redirect_to @url }
      else
        flash.now[:error] = url_taken ? url_taken : @url.errors.full_messages[0]
        format.html { render action: 'new' }
      end
    end
  end
end