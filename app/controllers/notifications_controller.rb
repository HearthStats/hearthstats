class NotificationsController < ApplicationController
  def note_read
    @note = Notification.find(params[:note_id])
    respond_to do |format|
      if @note.receipts.first.is_unread?
        current_user.mark_as_read @note
        format.js
      else
        # format.js { render :file => "already_read.js" }
      end
    end
  end
end
