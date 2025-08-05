class TripsController < ApplicationController
  # Allow anyone to browse community list and individual trips
  before_action :authenticate_user!, except: [:public_index, :show]

  # Load trip flexibly: any trip for show/duplicate, only owner for modifications
  before_action :set_trip, only: [:edit, :update, :destroy, :duplicate, :generate_ai_suggestions, :add_multiple_suggestions]
  # Owners can modify/edit; anyone logged-in can duplicate
  before_action :authorize_owner!, only: [:edit, :update, :destroy, :generate_ai_suggestions, :add_multiple_suggestions]
  # Detect where user came from to adjust back-link
  # detect_source removed; inline detection in show

  # GET /trips/community
  def public_index
    @trips = Trip.community_trips(current_user)
  end

  # GET /trips/:id
  def show
    @trip = Trip.find(params[:id])

    # Determine if user came from community index for back link label
    @came_from_community = request.referer&.include?(public_index_trips_url)

    # Guests and non-owners may only view if the trip is public
    unless @trip.public? || (user_signed_in? && current_user == @trip.user)
      return redirect_to trips_path, alert: "You don’t have permission to view that trip."
    end

    @checklist_items = @trip.checklist_items.includes(:item)
  end

  # GET /trips
  def index
    @trips = current_user.trips
    @upcoming_trips = current_user.trips.where("start_date >= ?", Date.current).order(start_date: :asc)
    @past_trips = current_user.trips.where("start_date < ?", Date.current).order(start_date: :desc)
  end

  # GET /trips/new
  def new
    @trip = Trip.new
  end

  # POST /trips
  def create
    @trip = current_user.trips.build(trip_params)

    if @trip.save
      add_default_items_to_trip
      redirect_to @trip, notice: "Trip created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /trips/:id/edit
  def edit; end

  # PATCH/PUT /trips/:id
  def update
    if @trip.update(trip_params)
      redirect_to @trip, notice: "Trip was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /trips/:id
  def destroy
    @trip.destroy
    redirect_to trips_url, notice: "Trip was successfully deleted."
  end

  # POST /trips/:id/duplicate
  def duplicate
    Trip.transaction do
      # Duplicate from unscoped Trip so non-owners can copy public trips
      original = Trip.find(params[:id])
      new_trip = original.dup
      new_trip.user = current_user
      new_trip.title = "#{original.title} (Copy)"
      new_trip.accommodation_type = original.accommodation_type
      new_trip.skip_date_validation = true
      new_trip.start_date = nil
      new_trip.end_date = nil

      if original.cover_image.attached?
        new_trip.cover_image.attach(
          io: StringIO.new(original.cover_image.download),
          filename: original.cover_image.filename.to_s,
          content_type: original.cover_image.content_type,
        )
      end

      new_trip.save!

      original.checklist_items.find_each do |ci|
        new_trip.checklist_items.create!(item: ci.item, checked: false)
      end

      # Redirect to edit page of the new trip
      redirect_to edit_trip_path(new_trip), notice: "Trip duplicated—edit your new copy now!"
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Trip duplication failed: #{e.record.errors.full_messages.join(", ")}"
    redirect_to trip_path(params[:id]), alert: "Failed to duplicate trip: #{e.record.errors.full_messages.join("; ")}"
  end

  # POST /trips/:id/generate_ai_suggestions
  def generate_ai_suggestions
    ai_response = @trip.generate_packing_suggestions
    @ai_suggestions = parse_ai_suggestions(ai_response)
    @checklist_items = @trip.checklist_items.includes(:item)
    render :show
  rescue StandardError => e
    Rails.logger.error "Failed to generate AI suggestions: #{e.message}"
    redirect_to @trip, alert: "Sorry, we couldn't generate suggestions right now. Please try again."
  end

  # POST /trips/:id/add_multiple_suggestions
  def add_multiple_suggestions
    suggestions = params[:suggestions]&.values.to_a.reject(&:blank?)
    added = 0

    suggestions.each do |name|
      next if @trip.checklist_items.joins(:item).where(items: { name: name }).exists?

      item = current_user.items.find_or_create_by(name: name) do |i|
        i.category = determine_category(name)
        i.reusable = false
      end

      @trip.checklist_items.create!(item: item, checked: false)
      added += 1
    end

    message = added.positive? ?
      "Added #{added} item#{"s" if added > 1}!" :
      "All selected items were already in your packing list."

    redirect_to @trip, notice: message
  rescue StandardError => e
    Rails.logger.error "Failed to add suggestions: #{e.message}"
    redirect_to @trip, alert: "There was an error adding items. Please try again."
  end

  private

  def set_trip
    @trip = case action_name
      when "show", "duplicate"
        Trip.find(params[:id])                    # allow any trip for viewing or copying
      else
        current_user.trips.find(params[:id])      # only owner for edits/updates/destroys
      end
  rescue ActiveRecord::RecordNotFound
    redirect_to public_index_trips_path, alert: "Trip not found."
  end

  def authorize_owner!
    return if user_signed_in? && @trip.user == current_user
    redirect_to trips_path, alert: "You’re not allowed to modify that trip."
  end

  def detect_source
    @came_from_community = request.referer&.include?(public_index_trips_url)
  end

  def trip_params
    params.require(:trip).permit(:title, :destination, :country, :accommodation_type,
                                 :start_date, :end_date, :cover_image, :public)
  end

  def add_default_items_to_trip
    current_user.items.reusable.find_each do |item|
      @trip.checklist_items.create!(item: item, checked: false)
    end
  end

  def parse_ai_suggestions(response)
    response.split("\n").map(&:strip)
            .reject(&:blank?)
            .reject { |l| l.match?(/^[A-Za-z ]+:$/) }
            .map { |l| l.gsub(/^[-*•]\s*/, "") }
            .select { |l| l.length > 2 }
            .first(30)
  end

  def determine_category(name)
    case name.downcase
    when /t-shirt|shirt|pants|jeans|dress|skirt|jacket|coat|sweater|hoodie|shorts|underwear|bra|socks|pajama|sleepwear/
      "clothing"
    when /phone|charger|camera|laptop|tablet|headphone|cable|adapter|battery|power.bank/
      "electronics"
    when /toothbrush|toothpaste|shampoo|soap|deodorant|perfume|makeup|skincare|razor|towel/
      "toiletries"
    when /passport|visa|ticket|insurance|license|document|id|card/
      "documents"
    when /medicine|pill|vitamin|bandaid|sunscreen|insect.repellent/
      "medication"
    when /book|guide|map|journal|pen|notebook/
      "miscellaneous"
    when /bag|suitcase|backpack|purse|wallet|sunglasses|hat|umbrella|watch/
      "accessory"
    when /snack|water|candy|fruit/
      "food"
    else
      "miscellaneous"
    end
  end
end
