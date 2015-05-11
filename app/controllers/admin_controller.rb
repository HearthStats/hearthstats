class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :admin_user?

  def index
  end

  def adtest
    render layout: false
  end

  def update_match_text
    udt_id = params[:match_string].first[0].to_i
    match_string = params[:match_string].first[1]
    unique_deck_type = UniqueDeckType.find(udt_id)
    unique_deck_type.archtype_id = params[:archtype_id][udt_id.to_s].to_i
    unique_deck_type.match_string = match_string
    if unique_deck_type.save
      redirect_to admin_verify_archtypes_path, notice: "Updated #{unique_deck_type.name}"
    else
      redirect_to admin_verify_archtypes_path, alert: "Error Updating #{unique_deck_type.name}"
    end
  end

  def verify_archtypes
    @unverified = UniqueDeckType.where(verified: false)
  end

  def approve_archtype
    archtype = UniqueDeckType.find(params[:ud_id])
    archtype.verified = true
    if archtype.save
      redirect_to admin_verify_archtypes_path, notice: "Approved #{archtype.name}"
    else
      redirect_to admin_verify_archtypes_path, alert: "DIDN'T WORK YO: #{archtype.name}"
    end
  end

  def disapprove_archtype
    unverified = UniqueDeckType.where(verified: false)
    unverified.each do |archtype|
      Deck.where(deck_type_id: archtype.id).update_all(deck_type_id: nil)
      archtype.destroy
    end

    redirect_to admin_verify_archtypes_path, notice: "BOOM ALL GONE"
  end

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

  def toggle_sub
    current_user.subscription_id =
      current_user.subscription_id.nil? ? 1 : nil

    if current_user.save
      redirect_to request.referer
    else
      redirect_to request.referer, alert: "Prem status not changed"
    end
  end

end
