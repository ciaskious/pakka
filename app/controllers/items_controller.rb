class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: %i[edit update destroy]

  def index
    @items = current_user.items
  end

  def show
    @item = current_user.items.find(params[:id])
    render partial: "item", locals: { item: @item }
  end

  def new
    @item = current_user.items.new
  end

  def create
    @item = current_user.items.new(item_params.merge(reusable: true))
    if @item.save
      redirect_to profile_path, notice: "Reusable item created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @item = current_user.items.find(params[:id])
    render partial: "items/edit", formats: [:html], locals: { item: @item }
  end

  def update
    @item = current_user.items.find(params[:id])
    if @item.update(item_params)
      html = render_to_string(partial: "items/item", formats: [:html], locals: { item: @item })
      render plain: html, content_type: "text/html"
    else
      render partial: "items/edit", locals: { item: @item }, status: :unprocessable_entity
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
