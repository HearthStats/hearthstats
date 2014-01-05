class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :adminboss

  def index
  end

  def new_patch

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

  def addid
  	constructed = Constructed.all
  	constructed.each do |c|
  		currentdeck = Deck.where(:name => c.deckname, :user_id => c.user_id)[0]
  		if currentdeck.nil?
  			c.deck_id = Deck.where(:name => c.deckname)[0]
  		else
	  		c.deck_id = currentdeck.id
	  	end
	  	c.save
  	end
  	redirect_to root_url, notice: 'SUCCESSSS'
  end

  def addprofileuserid
    users = User.all
    users.each do |c|
      p = Profile.new
      p.user_id = c.id
      p.save
    end
    redirect_to root_url, notice: 'SUCCESSSS PROFILE'
  end

  private

  def adminboss
    if current_user.id != 1
      redirect_to '/'
    end
  end
end
