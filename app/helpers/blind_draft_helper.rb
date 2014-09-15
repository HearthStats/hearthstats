module BlindDraftHelper
  def in_draft?(blind_draft)
    [ blind_draft.player1_id ,blind_draft.player2_id ].include? current_user.id
  end
end
