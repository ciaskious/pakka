class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:edit, :update, :destroy]

  def index
    @items = current_user.items
  end

  def show
    @item = current_user.items.find(params[:id])
  end

  def new
    @item = current_user.items.new
  end

  def create
    @item = current_user.items.new(item_params)
    if @item.save
      redirect_to profile_path, notice: "Item created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @item = current_user.items.find(params[:id])
    render partial: "items/form", locals: { item: @item }
  end

  def update
    @item = current_user.items.find(params[:id])
    if @item.update(item_params)
      render partial: "items/item", locals: { item: @item }
    else
      render partial: "items/form", locals: { item: @item }, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    redirect_to profile_path, notice: "Item deleted."
  end

  private

  def set_item
    @item = current_user.items.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :category)
  end
end
