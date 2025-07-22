class ChecklistItemsController < ApplicationController
  def create
    @trip = Trip.find(params[:trip_id])
    @checklist_item = @trip.checklist_items.new(checklist_item_params)

    if @checklist_item.checked.nil?
      @checklist_item.checked = false
    end

    if @checklist_item.item_id.present? && @checklist_item.name.blank?
      @checklist_item.name = @checklist_item.item.name
    end

    if @checklist_item.save
      redirect_to @trip, notice: "Item added!"
    else
      puts @checklist_item.errors.full_messages
      redirect_to @trip, alert: "Failed to add item."
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
    params.require(:checklist_item).permit(:name, :item_id, :checked, :category)
  end
end
