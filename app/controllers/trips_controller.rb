class TripsController < ApplicationController
  before_action :set_trip, only: [:show, :edit, :update, :destroy, :duplicate, :public_show]

  def index
    @trips = Trip.all

  end

  def show
    @checklist_items = @trip.checklist_items.includes(:likes)
  end

  def new
    @trip = Trip.new
  end

  def create
    @trip = Trip.new(trip_params)


    if @trip.save
      redirect_to @trip, notice: 'Trip was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @trip.update(trip_params)
      redirect_to @trip, notice: 'Trip was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @trip.destroy
    redirect_to trips_url, notice: 'Trip was successfully deleted.'
  end

  def duplicate
    @new_trip = @trip.dup
    @new_trip.title = "#{@trip.title} (Copy)"
    @new_trip.start_date = nil
    @new_trip.end_date = nil

    if @new_trip.save
      # Dupliquer les checklist_items
      @trip.checklist_items.each do |item|
        @new_trip.checklist_items.create(
          name: item.name,
          checked: false,
          ai_data: item.ai_data,
          item: item.item
        )
      end

      redirect_to @new_trip, notice: 'Trip was successfully duplicated.'
    else
      redirect_to @trip, alert: 'Failed to duplicate trip.'
    end
  end

  # GET /trips/:id/share (public_show)
  def public_show
    # Vue publique du trip (sans possibilité de modification)
    @checklist_items = @trip.checklist_items.includes(:likes)
    render :show
  end

  # GET /community (public_index)
  def public_index
    @trips = Trip.all
    # TODO: Filtrer les trips publics quand cette fonctionnalité sera ajoutée
    # @trips = Trip.where(public: true)
  end

  private

  def set_trip
    @trip = Trip.find(params[:id])
  end

  def trip_params
    params.require(:trip).permit(:title, :description, :destination, :country, :start_date, :end_date)
  end
end
