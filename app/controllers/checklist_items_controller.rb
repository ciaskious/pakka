class ChecklistItemsController < ApplicationController
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

  def destroy
    @checklist_item = ChecklistItem.find(params[:id])
    trip = @checklist_item.trip
    @checklist_item.destroy
    redirect_to trip, notice: "Item deleted."
  end
end
