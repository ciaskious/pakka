class ItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    @item = current_user.items.build(item_params)
    if @item.save
      redirect_to profile_path, notice: "Reusable item created."
    else
      redirect_to profile_path, alert: @item.errors.full_messages.to_sentence
    end
  end

  def destroy
    @item = current_user.items.find(params[:id])
    @item.destroy
    redirect_to profile_path, notice: "Reusable item deleted."
  end

  private

  def item_params
    params.require(:item).permit(:name, :category)
  end
end
