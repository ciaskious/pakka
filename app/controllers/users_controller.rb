class UsersController < ApplicationController
  before_action :authenticate_user!

  def profile
    @item = Item.new
    @items = current_user.items
  end
end
