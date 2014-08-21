class BlindDraftsController < ApplicationController
  before_filter :authenticate_user!, except: :show

  def index

  end

  def new
    @blind_draft = BlindDraft.new

    respond_to do |format|
      format.html
    end
  end

  def create
    @blind_draft = BlindDraft.new(params[:blind_draft])
    respond_to do |format|
      if @blind_draft.save
        format.html { redirect_to draft_blind_draft_path(@blind_draft), 
                      notice: "Blind Draft Successfully created." }
      else
        format.html { render action: "new" }
      end
    end

  end

  def draft
    @blind_draft = BlindDraft.find(params[:id])
  end

  def reveal_card
    card = BlindDraftCard.find(params[:draft_card])
    card.revealed = true

    respond_to do |format|
      if card.save
        format.html { redirect_to draft_blind_draft_path(card.blind_draft) }
      else
        format.html { render action: "draft" }
      end
    end
  end

  def pick_card
    card = BlindDraftCard.find(params[:draft_card])
    card.user_id = params[:player_id]

    respond_to do |format|
      if card.save
        format.html { redirect_to draft_blind_draft_path(card.blind_draft) }
      else
        format.html { render action: "draft" }
      end
    end
  end

end
