class UsersController < ApplicationController
  before_action :authenticate_user!

  def profile
    @item = Item.new
    @items = current_user.items
    @past_trips = current_user.trips.order(created_at: :desc) # or however you define "past"
    @items = current_user.items.reusable
    @reusable_items = ReusableItem.where(user: current_user)
  end

  def update_avatar
    if current_user.update(avatar_params)
      redirect_to profile_path, notice: "Avatar updated!"
    else
      redirect_to profile_path, alert: "Failed to update avatar."
    end
  end

  private

  def avatar_params
    params.require(:user).permit(:avatar)
  end
end
