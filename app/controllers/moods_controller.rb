class MoodsController < ApplicationController
  before_filter :if_not_signed_in
  before_action :set_mood, only: [:show, :edit, :update, :destroy]

  # GET /moods
  # GET /moods.json
  def index
    @moods = Mood.where(:userid => current_user.id).all
    @page_title = "Moods"
  end

  # GET /moods/1
  # GET /moods/1.json
  def show
    if @mood.userid == current_user.id
      @page_title = @mood.name
    else 
      respond_to do |format|
        format.html { redirect_to moods_url }
        format.json { head :no_content }
      end
    end
  end

  # GET /moods/new
  def new
    @mood = Mood.new
    @page_title = "New Mood"
  end

  # GET /moods/1/edit
  def edit
    if @mood.userid == current_user.id
      @page_title = "Edit " + @mood.name
    else
      respond_to do |format|
        format.html { redirect_to moods_url }
        format.json { head :no_content }
      end
    end 
  end

  # POST /moods
  # POST /moods.json
  def create
    @mood = Mood.new(mood_params)

    respond_to do |format|
      if @mood.save
        format.html { redirect_to @mood, notice: 'Mood was successfully created.' }
        format.json { render :show, status: :created, location: @mood }
      else
        format.html { render :new }
        format.json { render json: @mood.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /moods/1
  # PATCH/PUT /moods/1.json
  def update
    respond_to do |format|
      if @mood.update(mood_params)
        format.html { redirect_to @mood, notice: 'Mood was successfully updated.' }
        format.json { render :show, status: :ok, location: @mood }
      else
        format.html { render :edit }
        format.json { render json: @mood.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /moods/1
  # DELETE /moods/1.json
  def destroy
    # Remove moods from existing triggers
    @triggers = Trigger.where(:userid => current_user.id).all

    @triggers.each do |item|
      new_category = item.mood.delete(@mood.id.to_s)
      the_trigger = Trigger.find_by(id: item.id)
      the_trigger.update(mood: item.mood)
    end

    @mood.destroy
    respond_to do |format|
      format.html { redirect_to moods_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mood
      @mood = Mood.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mood_params
      params.require(:mood).permit(:name, :description, :userid)
    end

    def if_not_signed_in
      if !user_signed_in?
        respond_to do |format|
          format.html { redirect_to new_user_session_path }
          format.json { head :no_content }
        end
      end
    end
end