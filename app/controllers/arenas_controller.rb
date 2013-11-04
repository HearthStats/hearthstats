class ArenasController < ApplicationController
  before_filter :authenticate_user!
  # GET /arenas
  # GET /arenas.json
  def index
    @arenas = Arena.where(user_id: current_user.id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @arenas }
    end
  end

  # GET /arenas/1
  # GET /arenas/1.json
  def show
    @arena = Arena.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @arena }
    end
  end

  # GET /arenas/new
  # GET /arenas/new.json
  def new
    @arena = Arena.new
    @lastentry = Arena.where(user_id: current_user.id).last
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @arena }
    end
  end

  # GET /arenas/1/edit
  def edit
    @arena = Arena.find(params[:id])
  end

  # POST /arenas
  # POST /arenas.json
  def create
    @arena = Arena.new(params[:arena])
    @arena.user_id = current_user.id
    respond_to do |format|
      if @arena.save
        format.html { redirect_to arenas_url, notice: 'Arena was successfully created.' }
        format.json { render json: @arena, status: :created, location: @arena }
      else
        format.html { render action: "new" }
        format.json { render json: @arena.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /arenas/1
  # PUT /arenas/1.json
  def update
    @arena = Arena.find(params[:id])

    respond_to do |format|
      if @arena.update_attributes(params[:arena])
        format.html { redirect_to arenas_url, notice: 'Arena was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @arena.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /arenas/1
  # DELETE /arenas/1.json
  def destroy
    @arena = Arena.find(params[:id])
    @arena.destroy

    respond_to do |format|
      format.html { redirect_to arenas_url }
      format.json { head :no_content }
    end
  end
end
