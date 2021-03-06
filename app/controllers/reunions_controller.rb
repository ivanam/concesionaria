class ReunionsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_reunion, only: [:show, :edit, :update, :destroy]


  # GET /reunions
  # GET /reunions.json
  def index
    @bg_white = true
    @anio = Date.today.year
    @mes = Date.today.month
    nombre_mes = I18n.t("date.month_names")[@mes]
    if !params[:date].blank?
      @anio = params[:date][:anio].to_i
      @mes = params[:date][:mes].to_i
      nombre_mes = I18n.t("date.month_names")[@mes]
    end
    if !params[:semana].blank?
      @semana = params[:semana].to_i
      @reunions = Reunion.where("YEAR(fecha) = ?", @anio).where(mes: nombre_mes, semana: @semana)
    else
      @reunions = Reunion.where("YEAR(fecha) = ?", @anio).where(mes: nombre_mes)
    end    
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => 'template_pdf', 
          :template => 'reunions/template_pdf.html.erb',
          :layout => 'pdf.html.erb',
          :orientation => 'Portrait',# default Portrait
          :page_size => 'Legal'
      end 
    end
  end

  # GET /reunionsm.pdf
  # Genera el template de Reuniones mensuales
  def reunion_mensual
    @reunions = Reunion.all
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => 'template_pdf', 
          :template => 'reunions/template_mensual_pdf.html.erb',
          :layout => 'pdf.html.erb',
          :orientation => 'Portrait',# default Portrait
          :page_size => 'Legal'
      end 
    end
  end

  # GET /reunions/1
  # GET /reunions/1.json
  def show
  end

  # GET /reunions/new
  def new
    @reunion = Reunion.new
  end

  # GET /reunions/1/edit
  def edit
  end

  # POST /reunions
  # POST /reunions.json
  def create
    @reunion = Reunion.new(reunion_params)
    @reunion.mes = I18n.t("date.month_names")[params[:date][:mes].to_i]
    respond_to do |format|
      if @reunion.save
        format.html { redirect_to @reunion, notice: 'Se ha creado una nueva Reunion.' }
        format.json { render :show, status: :created, location: @reunion }
      else
        format.html { render :new }
        format.json { render json: @reunion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reunions/1
  # PATCH/PUT /reunions/1.json
  def update
    respond_to do |format|
      @reunion.mes = I18n.t("date.month_names")[params[:date][:mes].to_i]
      if @reunion.update(reunion_params)
        format.html { redirect_to @reunion, notice: 'Se ha actualizado la Reunion.' }
        format.json { render :show, status: :ok, location: @reunion }
      else
        format.html { render :edit }
        format.json { render json: @reunion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reunions/1
  # DELETE /reunions/1.json
  def destroy
    @reunion.reunion_participantes.destroy_all
    @reunion.destroy
    respond_to do |format|
      format.html { redirect_to reunions_url, notice: 'Se ha eliminado la Reunion.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reunion
      @reunion = Reunion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reunion_params
      params.require(:reunion).permit(:fecha, :semana, :mes, :lugar_fisico, :persona_id, :plan_accion, :accion, :adjunto, :adjunto_file_name, :mensual, reunion_participantes_attributes: [:id, :persona_id, :_destroy])
    end
end
