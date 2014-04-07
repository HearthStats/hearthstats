class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :adminboss

  def index
  end

  def new_patch

  end

  def test_excep
		raise CustomException, "A custom message"
  end

  def update_patch
  	current_con = Constructed.where(:patch => "current")
  	current_arena_run = ArenaRun.where(:patch => "current")

		if current_arena_run.update_all(:patch => params[:patch]) && current_con.update_all(:patch => params[:patch])
			redirect_to admin_index_path, notice: 'Patch Versioned'
	  else
	  	render action: "update_patch"
	  end

  end

  def announcement
    @ann = Announcement.new
    @annrec = Announcement.last(5).reverse
  end

  def anncreate
    @ann = Announcement.new(params[:announcement])
    respond_to do |format|
      if @ann.save
        format.html { redirect_to admin_index_path, notice: 'Announcement was successfully created.' }
        format.json { render json: @ann, status: :created, location: @ann }
      else
        format.html { render action: "announcement" }
        format.json { render json: @ann.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def adminboss
    if current_user.id != 710
      redirect_to '/'
    end
  end

end
