module Commontator
  class Subscription < ActiveRecord::Base
    belongs_to :subscriber, :polymorphic => true
    belongs_to :thread

    validates_presence_of :subscriber, :thread
    validates_uniqueness_of :thread_id, :scope => [:subscriber_type, :subscriber_id]

    def self.comment_created(comment)
      recipients = comment.thread.subscribers
      return if recipients.empty?

      if Rails.env.development?
        p "Email sent to: " + recipients.inspect
        SubscriptionsMailer.comment_created(comment, recipients).deliver
      else
        SubscriptionsMailer.delay.comment_created(comment, recipients)
      end
    end

    def unread_comments
      created_at = Comment.arel_table[:created_at]
      thread.filtered_comments.where(created_at.gt(updated_at))
    end
  end
end
