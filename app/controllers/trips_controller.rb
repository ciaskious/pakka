class TripsController < ApplicationController
  before_action :authenticate_user!, except: %i[public_index public_show]
  before_action :set_trip, only: %i[show edit update destroy duplicate generate_ai_suggestions add_multiple_suggestions]
  before_action :set_public_trip, only: [:public_show]

  def index
    @trips = current_user.trips
  end

  def show
    @trip = Trip.find(params[:id])
    @checklist_items = @trip.checklist_items.includes(:item)
  end

  def new
    @trip = Trip.new
  end

  def create
    @trip = Trip.new(trip_params)
    @trip.user = current_user

    if @trip.save
      # Automatically add user's reusable items
      add_default_items_to_trip

      redirect_to @trip, notice: "Trip created!"
    else
      puts @trip.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @trip.update(trip_params)
      redirect_to @trip, notice: "Trip was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @trip.destroy
    redirect_to trips_url, notice: "Trip was successfully deleted."
  end

  def duplicate
    # Wrap in a transaction so we roll back if anything goes wrong
    Trip.transaction do
      # 1) Duplicate the trip itself (this carries over user_id but not timestamps or PK)
      @new_trip = @trip.dup
      @new_trip.user = current_user
      @new_trip.title = "#{@trip.title} (Copy)"
      @new_trip.start_date = nil
      @new_trip.end_date = nil

      # 2) Re‐attach any cover_image
      if @trip.cover_image.attached?
        @new_trip.cover_image.attach(
          io: StringIO.new(@trip.cover_image.download),
          filename: @trip.cover_image.filename.to_s,
          content_type: @trip.cover_image.content_type,
        )
      end

      # 3) Save the new trip (this will raise if invalid)
      Rails.logger.debug "Duping: user=#{@new_trip.user_id}, valid?=#{@new_trip.valid?}, errors=#{@new_trip.errors.full_messages}"

      @new_trip.save!

      # 4) Duplicate each checklist item
      @trip.checklist_items.find_each do |ci|
        @new_trip.checklist_items.create!(
          item: ci.item,
          name: ci.name,
          checked: false,
        )
      end

      # 5) Redirect on success
      redirect_to @new_trip, notice: "Trip was successfully duplicated."
    end
  rescue ActiveRecord::RecordInvalid => e
    # If anything failed in the transaction, roll back and show errors
    Rails.logger.error "Trip duplication failed: #{e.record.errors.full_messages.join(", ")}"
    redirect_to @trip, alert: "Failed to duplicate trip: #{e.record.errors.full_messages.join("; ")}"
  end

  # GET /trips/:id/share (public_show)
  def public_show
    @trip = Trip.find(params[:id]) # don’t scope to current_user
    @checklist_items = @trip.checklist_items.includes(:likes)
    render :show
  end

  # GET /community (public_index)
  def public_index
    # @trips = current_user.all
    # TODO: Filter public trips when this feature is added
    @trips = Trip.where(public: true)
  end

  def generate_ai_suggestions
    ai_response = @trip.generate_packing_suggestions

    # Parse suggestions into individual items
    @ai_suggestions = parse_ai_suggestions(ai_response)

    # Load checklist items for the show view
    @checklist_items = @trip.checklist_items.includes(:item)

    # Debug to see what happens
    Rails.logger.info "AI Suggestions generated: #{@ai_suggestions.inspect}"

    respond_to do |format|
      format.html { render :show }  # Re-render the show view with suggestions
    end
  rescue StandardError => e
    Rails.logger.error "Failed to generate AI suggestions: #{e.message}"
    redirect_to @trip, alert: "Sorry, we couldn't generate suggestions right now. Please try again."
  end

  def add_multiple_suggestions
    selected_suggestions = params[:suggestions]&.values&.reject(&:blank?) || []

    if selected_suggestions.any?
      added_count = 0
      selected_suggestions.each do |suggestion|
        # Check if item already exists
        existing_item = @trip.checklist_items.joins(:item).where(items: { name: suggestion }).exists?

        unless existing_item
          # Create or find item for this user
          item = current_user.items.find_or_create_by(name: suggestion) do |new_item|
            new_item.category = determine_category(suggestion)
            new_item.reusable = false  # AI suggestions are not reusable by default
          end

          # Create checklist_item
          @trip.checklist_items.create!(item: item, checked: false)
          added_count += 1
        end
      end

      message = if added_count > 0
          "Successfully added #{added_count} item#{added_count > 1 ? "s" : ""} to your packing list!"
        else
          "All selected items were already in your packing list."
        end

      redirect_to @trip, notice: message
    else
      redirect_to @trip, alert: "Please select at least one item to add."
    end
  rescue StandardError => e
    Rails.logger.error "Failed to add multiple suggestions: #{e.message}"
    redirect_to @trip, alert: "Sorry, there was an error adding the items. Please try again."
  end

  private

  def parse_ai_suggestions(ai_response)
    # Split response into lines and clean
    suggestions = ai_response.split("\n")
      .map(&:strip)
      .reject(&:empty?)
      .reject { |line| line.match?(/^[A-Za-z\s]+:$/) } # Remove category titles
      .map { |line| line.gsub(/^[-*•]\s*/, "") } # Remove bullets
      .reject { |line| line.match?(/^(Clothing|Electronics|Personal Care|Documents|Toiletries|Accessories|Shoes|Health|Safety|Travel|Miscellaneous):?$/i) } # Remove category headers
      .select { |line| line.length > 2 } # Keep only real items

    suggestions.first(30) # Limit to 30 suggestions max
  end

  def determine_category(item_name)
    item_lower = item_name.downcase

    case item_lower
    when /t-shirt|shirt|pants|jeans|dress|skirt|jacket|coat|sweater|hoodie|shorts|underwear|bra|socks|pajama|sleepwear/
      "clothing"
    when /shoe|boot|sandal|sneaker|heel|flip.flop/
      "clothing"  # footwear doesn't exist, use clothing
    when /phone|charger|camera|laptop|tablet|headphone|cable|adapter|battery|power.bank/
      "electronics"
    when /toothbrush|toothpaste|shampoo|soap|deodorant|perfume|makeup|skincare|razor|towel/
      "toiletries"
    when /passport|visa|ticket|insurance|license|document|id|card/
      "documents"
    when /medicine|pill|vitamin|bandaid|sunscreen|insect.repellent/
      "medication"  # health_and_safety doesn't exist, use medication
    when /book|guide|map|journal|pen|notebook/
      "miscellaneous"  # entertainment doesn't exist
    when /bag|suitcase|backpack|purse|wallet|sunglasses|hat|umbrella|watch/
      "miscellaneous"  # accessories doesn't exist
    when /snack|water|candy|fruit/
      "food"
    else
      "miscellaneous"
    end
  end

  def set_trip
    @trip = current_user.trips.find_by(id: params[:id])
    redirect_to trips_path, alert: "Trip not found" unless @trip
  end

  def set_public_trip
    @trip = Trip.find_by(id: params[:id])
    redirect_to public_index_trips_path, alert: "Trip not found" unless @trip
  end

  def trip_params
    params.require(:trip).permit(:title, :destination, :country, :accommodation_type, :start_date, :end_date, :cover_image)
  end

  def add_default_items_to_trip
    # Add all user's reusable items to the new trip
    current_user.items.reusable.each do |item|
      @trip.checklist_items.create!(
        item: item,
        checked: false,
      )
    end
  end
end
