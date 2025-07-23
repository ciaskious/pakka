class UsersController < ApplicationController
  before_action :authenticate_user!

  def profile
    @item = Item.new
    @items = current_user.items
  end

  private

  def user_params
    params.require(:user).permit(:avatar)
  end
end
