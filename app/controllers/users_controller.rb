class UsersController < ApplicationController
  before_action :authenticate_user!

  def profile
    @item = Item.new
    @items = current_user.items
    @past_trips = current_user.trips.order(created_at: :desc) # or however you define "past"
    @items = current_user.items.reusable
    @favorite_destination, @favorite_destination_count = current_user.favorite_destination_info
  end

  def update_avatar
    if current_user.update(avatar_params)
      redirect_to profile_path, notice: "Avatar updated!"
    else
      redirect_to profile_path, alert: "Failed to update avatar."
    end
  end

  def favorite_destination
    trips.favorite_destination
  end

  def favorite_destination_count
    return 0 unless favorite_destination

    trips.where(destination: favorite_destination).count
  end

  private

  def avatar_params
    params.require(:user).permit(:avatar)
  end
end
