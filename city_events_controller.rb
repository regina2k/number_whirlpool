class CityEventsController < AdminController
  before_filter :find, only: [:edit, :update, :show, :destroy]
  before_filter :find_places, only: [:edit, :update]


  def index
    @q = CityEvent.in_current_city
    if params[:has_tag].present?
      @q = @q.with_tag(params[:has_tag].to_i)
    end
    @q = @q.search(params[:q])
    @events = @q.result(distinct: true).includes(:event_times,  :places).page(params[:page])
  end


  def edit

  end


  def new
    @event = CityEvent.new
  end


  def destroy
    if @event.destroy
      flash[:notice] = 'Событие удалено.'
      redirect_to city_events_path
    else
      redirect_to @event
    end
  end


  def update
    if params[:city_event].present? && @event.update_attributes(city_event_params)
      flash[:notice] = 'Изменения сохранены.'
      render :action => 'edit'
    else
      render :action => 'edit'
    end

  end


  def show

  end


  def create
    @event = CityEvent.new(city_event_params)

    if @event.save
      redirect_to edit_city_event_path(@event), notice: 'Cобытие добавлено.'
    else
      flash.now[:alert] = 'Произошла ошибка'
      render action: 'new'
    end
  end


  protected


  def event_type
    if params['event_type_id'].present?
      {:event_type_id => params['event_type_id']}
    else
      {}
    end
  end


  def find
    @event = CityEvent.includes(:source_links).find(params[:id])
  end


  def city_event_params
    params.require(:city_event).permit(:event_type_id, :place_id, :price_from, :price_to, :name, :annotation, :description, :url, :published, multi_image_links: [], tag_ids: [], place_ids: [])
  end


  def find_places
    @places = Place.in_current_city.reorder('name asc')
  end
end