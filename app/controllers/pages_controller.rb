class PagesController < ApplicationController
  def home
    if user_signed_in?
      @my_trips = current_user.trips
      @community_trips = Trip.where(public: true).where.not(user: current_user).includes(:user)
    else
      @my_trips = []
      @community_trips = Trip.where(public: true)
    end
    @trips = Trip.includes(:user).all
  end

  def ui_kit
  end
end
