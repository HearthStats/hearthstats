class BlindDraftsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @blind_drafts = current_user.blind_drafts.order(:created_at).reverse
  end

  def new
    @blind_draft = BlindDraft.new

    respond_to do |format|
      format.html
    end
  end

  def create
    @blind_draft = BlindDraft.new(params[:blind_draft])
    @blind_draft.player2_id = User.find_user(params[:opponent]).try(:id)
    klass_string = Klass.list.sample(5).join(",")
    @blind_draft.klass_string = klass_string
    respond_to do |format|
      if @blind_draft.player2_id.nil? && @blind_draft.public == true
        @blind_draft.save
        format.html { redirect_to draft_blind_draft_path(@blind_draft), 
                      notice: "Blind Draft Successfully created." }
      else
        format.html { render action: "new" }
      end
    end

  end

  def show
    @blind_draft = BlindDraft.find(params[:id])
    authenticate_drafters
  end

  def draft
    @blind_draft = BlindDraft.find(params[:id])
    if @blind_draft.player2_id.nil?
      redirect_to blind_drafts_path, alert: "Waiting on a player to join the draft" and return
    end
    authenticate_drafters
  end

  def reveal_card
    card = BlindDraftCard.find(params[:blind_draft_card])

    respond_to do |format|
      if card.update_attribute(:revealed, true)
        sync_update card
        format.html { redirect_to draft_blind_draft_path(card.blind_draft) }
        format.js
      else
        format.html { render action: "draft" }
      end
    end
  end

  def pick_card
    card = BlindDraftCard.find(params[:draft_card])

    respond_to do |format|
      if card.update_attribute(:user_id, params[:player_id])
        sync_update card
        sync_update card.blind_draft
        format.html { redirect_to draft_blind_draft_path(card.blind_draft) }
        format.js
      else
        format.html { render action: "draft" }
      end
    end
  end

  private

    def authenticate_drafters
      unless [ @blind_draft.player1_id ,@blind_draft.player2_id ].include? current_user.id || current_user.has_role?(:caster)
        redirect_to blind_drafts_path, alert: "You are not a member of that draft"
      end
    end
end
