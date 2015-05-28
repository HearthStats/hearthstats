class BlindDraftsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authenticate_drafters_or_caster, :only => [:draft, :show]
  before_filter :authenticate_drafters, :only => [:end_draft, :pick_card, :reveal_card]

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
      if @blind_draft.player2_id || (@blind_draft.player2_id.nil? && @blind_draft.public == true)
        @blind_draft.save
        @blind_draft.player2.notify("Blind Draft Challenge",
        "You have been invited to a Blind Draft by #{@blind_draft.player2.name}",
        @blind_draft)
        format.html { redirect_to draft_blind_draft_path(@blind_draft), 
                      notice: "Blind Draft Successfully created." }
      else
        format.html { render action: "new" }
      end
    end

  end

  def draft
    @blind_draft = BlindDraft.find(params[:id])
    if @blind_draft.player2_id.nil?
      redirect_to blind_drafts_path, alert: "Waiting on a player to join the draft" and return
    end
  end

  def end_draft
    @blind_draft = BlindDraft.find(params[:id])
    @blind_draft.complete = true
    if @blind_draft.save!
      redirect_to blind_draft_path(@blind_draft), notice: "Draft Completed"
    else
      redirect_to draft_blind_draft_path(@blind_draft), alert: "Could not complete draft"
    end
  end

  def new_card
    blind_card           = BlindDraftCard.find(params[:blind_draft_card])
    blind_draft          = BlindDraft.find(params[:id])
    blind_draft_card_ids = blind_draft.cards.map(&:id)
    left_over_cards      = Card.where(klass_id: nil, collectible: true).map(&:id) \
      - blind_draft_card_ids
    blind_card.card_id = left_over_cards.sample
    respond_to do |format|
      if blind_card.save
        sync_update blind_card
        format.html { redirect_to draft_blind_draft_path(blind_draft) }
        format.js
      end
    end
  end

  def show
    @blind_draft = BlindDraft.find(params[:id])
    unless @blind_draft.complete
      redirect_to draft_blind_draft_path(@blind_draft) and return
    end
    player1_deck = @blind_draft.player1_cards.map { |b_card| [b_card.card,1] }
    @player1_deck = player1_deck.sort_by { |card| card[0].mana }
    player2_deck = @blind_draft.player2_cards.map { |b_card| [b_card.card,1] }
    @player2_deck = player2_deck.sort_by { |card| card[0].mana }
    current_player_cards = @blind_draft.find_player_cards(current_user.id)
    @cardstring = current_player_cards.map {|b_card| b_card.card.id.to_s + "_1"}.join(",")
  end

  def create_deck
    blind_draft = BlindDraft.find(params[:id])
    klass_id = Klass::LIST.invert[params[:klass]]
    deck = Deck.new(name:       "Blind Draft #{blind_draft.id}",
                    klass_id:   klass_id,
                    cardstring: params[:cardstring],
                    user_id:    current_user.id)
    if deck.save
      redirect_to deck_path(deck), notice: "Deck created"
    else
      redirect_to blind_draft_path(blind_draft), alert: "Deck could not be created"
    end
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
      if card.update_attribute(:user_id, current_user.id)
        sync_update card
        sync_update card.blind_draft
        format.html { redirect_to draft_blind_draft_path(card.blind_draft) }
        format.js
      else
        format.html { render action: "draft" }
      end
    end
  end

  def destroy
    blind_draft = BlindDraft.find(params[:id])
    blind_draft.destroy
    respond_to do |format|
      format.html { redirect_to blind_drafts_path, notice: "Blind Draft Deleted" }
    end
  end

  private

  def closed_redirect
    redirect_to root_path, alert: "Sadly Blind Draft is close due to lack of use. We would love to bring it back if you can show us there is love for this!"
  end

  def authenticate_drafters_or_caster
    blind_draft = BlindDraft.find(params[:id])
    unless current_user.has_role?(:caster) || ([ blind_draft.player1_id ,blind_draft.player2_id ].include? current_user.id)
      redirect_to blind_drafts_path, alert: "You are not a member of that draft"
    end
  end

  def authenticate_drafters
    blind_draft = BlindDraft.find(params[:id])
    unless [ blind_draft.player1_id ,blind_draft.player2_id ].include? current_user.id
      redirect_to blind_drafts_path, alert: "You are not a member of that draft"
    end
  end
end
