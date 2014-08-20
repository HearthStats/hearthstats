module WelcomeHelper
  def group_by_date
    created_at.to_date
  end
end
