class ChecklistItemsController < ApplicationController
  def edit
    @item = current_user.items.find(params[:id])
    render partial: "checklist_items/edit", formats: [:html], locals: { item: @item }
  end

  def update
    @checklist_item = ChecklistItem.find(params[:id])
    if @checklist_item.update(checklist_item_params)
      html = render_to_string(partial: "checklist_items/checklist_item", formats: [:html], locals: { checklist_item: @checklist_item })
      render plain: html, content_type: "text/html"
    else
      render partial: "checklist_items/edit", locals: { checklist_item: @checklist_item }, status: :unprocessable_entity
    end
  end

  def create
    @trip = Trip.find(params[:trip_id])

    item_name = params[:name]
    item_category = params[:category]

    if item_name.blank? || item_category.blank?
      redirect_to @trip, alert: "Name and category are required."
      return
    end

    # Create a non-reusable item
    item = Item.new(
      name: item_name,
      category: item_category,
      reusable: false,
      user_id: current_user.id,
    )

    if item.save
      @checklist_item = @trip.checklist_items.new(
        item: item,
        name: item.name,
        checked: false,
      )

      if @checklist_item.save
        redirect_to @trip, notice: "Item added!"
      else
        logger.error "❌ ChecklistItem errors: #{@checklist_item.errors.full_messages}"

        redirect_to @trip, alert: "Failed to save checklist item: #{@checklist_item.errors.full_messages.join(", ")}"
      end
    else
      logger.error "❌ Item errors: #{item.errors.full_messages}"

      redirect_to @trip, alert: "Failed to create item: #{item.errors.full_messages.join(", ")}"
    end
  end

  def toggle
    @checklist_item = ChecklistItem.find(params[:id])
    @checklist_item.update(checked: params[:checked])

    respond_to do |format|
      format.json { render json: { status: :ok } }
    end
  end

  def destroy
    @checklist_item = ChecklistItem.find(params[:id])
    trip = @checklist_item.trip
    @checklist_item.destroy
    redirect_to trip, notice: "Item deleted."
  end

  private

  def checklist_item_params
    params.require(:checklist_item).permit(:checked, :name, item_attributes: [:id, :name, :category])
  end
end
