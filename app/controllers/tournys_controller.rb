class TournysController < ApplicationController
  layout false

  def index
  end

  def signup
  end

  def past
  end

  def regtourny
    respond_to do |format|
      format.js
    end
  end
end
