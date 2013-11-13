class DecksController < ApplicationController
  before_filter :authenticate_user!
  # GET /decks
  # GET /decks.json
  def index
    @decks = Deck.where(:user_id => current_user.id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @decks }
    end
  end

  # GET /decks/1
  # GET /decks/1.json
  def show
    require 'rubygems'
    require 'nokogiri' 
    require 'open-uri'        
    @deck = Deck.find(params[:id])

    
    if @deck.decklink.nil? || @deck.decklink.blank?
      @page = "No deck link attatched to this deck yet <p>"
    else
      _link = @deck.decklink
      begin
        u=URI.parse(_link)
        if (!u.scheme)
            link = "http://" + _link
        else
            link = _link
        end
        @page = Nokogiri::HTML(open(link))
        if !@page.css('header').text.blank?
          @page = "<a href='#{link}'>Link To Deck</a><p>"
        else
          @page =  @page.text
        end
      rescue
        if _link == "/export/4"
          @page = "No deck link attatched to this deck yet 11<p>"
        else
          link = link[0..-10]
          @page = "<a href='#{link}'>Link To Deck</a><p>"
        end     
      end
    end
     

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @deck }
    end
  end

  # GET /decks/new
  # GET /decks/new.json
  def new
    @deck = Deck.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @deck }
    end
  end

  # GET /decks/1/edit
  def edit
    @deck = Deck.find(params[:id])
    canedit(@deck)
  end

  # POST /decks
  # POST /decks.json
  def create
    @deck = Deck.new(params[:deck])
    @deck.user_id = current_user.id
    respond_to do |format|
      if @deck.save
        format.html { redirect_to @deck, notice: 'Deck was successfully created.' }
        format.json { render json: @deck, status: :created, location: @deck }
      else
        format.html { render action: "new" }
        format.json { render json: @deck.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /decks/1
  # PUT /decks/1.json
  def update
    @deck = Deck.find(params[:id])
    contructed = Constructed.where(:deck_id => @deck.id).update_all(:deckname => params[:deck]['name'])

    respond_to do |format|
      if @deck.update_attributes(params[:deck])
        format.html { redirect_to @deck, notice: 'Deck was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @deck.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /decks/1
  # DELETE /decks/1.json
  def destroy
    @deck = Deck.find(params[:id])
    @deck.destroy
    respond_to do |format|
      format.html { redirect_to decks_url }
      format.json { head :no_content }
    end
  end
end
