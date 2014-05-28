class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :admin_user?

  def export_con
    matches = Match.where(season_id: current_season, mode_id: 3)
    respond_to do |format|
      format.csv { render text: matches.to_csv }
    end
  end

  def export_arena
    matches = Match.where(season_id: current_season, mode_id: 1)
    respond_to do |format|
      format.csv { render text: matches.to_csv }
    end
  end

  def ann
  	@ann = Annoucement.new
  	@annrec = Annoucement.last(10)
  end

  def anncreate
  	@ann = Annoucement.new(params[:annoucement])
  	if @ann.save
			redirect_to root_path, notice: "New annoucement created!"
		else
			redirect_to 'admin/ann'
		end
  end

  private

  def admin_user?
  	if !current_user.is_admin?
  		redirect_to root_path, alert: "Y U NO ADMIN"
  	end
	end
end
