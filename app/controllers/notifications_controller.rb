class NotificationsController < ApplicationController
	def note_read
		note = Notification.find(params[:note_id])
		current_user.mark_as_read note
	end
end