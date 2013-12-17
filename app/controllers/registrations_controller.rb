class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
  	destroy_guest
    super
    c = Cindy.new "http://sendy.hearthstats.net", "cGF9DlbzfS0jBooMv5N3"
    if resource.save
    	c.subscribe "aQOe0RrtTXddPhL9p28929MA", resource.email
    end
  end

  def update
    super
  end
end
