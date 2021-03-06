class VendedorsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_vendedor, only: [:show, :edit, :update, :destroy]

  # GET /vendedors
  # GET /vendedors.json
  def index
    @bg_gray = true
    @vendedors = Vendedor.where(punto_venta_id: current_user.punto_venta_id).where('baja is null or baja = false')
  end

  # GET /vendedors/1
  # GET /vendedors/1.json
  def show
    @bg_gray = true
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => 'obj_vend_pdf', 
          :template => 'vendedors/obj_vend_pdf.html.erb',
          :layout => 'pdf.html.erb',
          :orientation => 'Portrait',# default Portrait
          :page_size => 'Legal'
      end
    end
  end

  # GET /vendedors/new
  def new
    @bg_gray = true

    @vendedor = Vendedor.new
    @persona = Persona.new
  end

  # GET /vendedors/1/edit
  def edit
    @vendedor = Vendedor.where(:id => params[:id]).first
    @persona  = @vendedor.persona
    @bg_gray = true

  end

  # POST /vendedors
  # POST /vendedors.json
  def create

    @vendedor = Vendedor.new(vendedor_params)
    if vendedor_params["punto_venta_id"].nil?
      @vendedor.punto_venta_id = current_user.punto_venta_id
    end
    if current_user.punto_venta.vendedors.order(:avance).last == nil
      @vendedor.avance = 1
    else
      @vendedor.avance = current_user.punto_venta.vendedors.order(:avance).last.avance.to_i + 1
    end
    
    if Persona.where(:cuit => params[:persona][:cuit]).first == nil
      @persona = Persona.new(persona_params)
    else
      @persona= Persona.where(:cuit => params[:persona][:cuit]).first
      @persona.tipo_documento_id=params[:persona][:tipo_documento_id]
      @persona.numero_documento=params[:persona][:numero_documento]
      @persona.apellido=params[:persona][:apellido]
      @persona.nombre=params[:persona][:nombre]
      @persona.domicilio=params[:persona][:domicilio]
      @persona.telefono=params[:persona][:telefono]
      @persona.fecha_nacimiento=params[:persona][:fecha_nacimiento]
      @persona.email=params[:persona][:email]
    end
    
   
    #el numero de vendedor debe ser unico
    respond_to do |format|
             if @persona.save
                 @vendedor.persona_id=@persona.id
                 if @vendedor.save

                    if @vendedor.persona.user != nil and @vendedor.persona.user.has_role? :punto_venta
                      format.html { redirect_to current_user.punto_venta, notice: 'Vendedor creado.' }

                    else
                      format.html { redirect_to @vendedor, notice: 'Vendedor creado..' }
                      format.json { render :show, status: :created, location: @vendedor }
                    end
                  
                 else
                    if @persona.user != nil and @persona.user.has_role? :punto_venta
                      flash[:error] = @vendedor.errors.messages.first[1][0]
                      
                      format.html { redirect_to vendedor_cambiar_rol_path(persona: @persona.id)} 
                      format.json { render json: @vendedor.errors, status: :unprocessable_entity }
                    else
                      format.html { render :new }
                      format.json { render json: @vendedor.errors, status: :unprocessable_entity }
                    end
                 end
             else
                if @persona.user != nil and @persona.user.has_role? :punto_venta
                    flash[:error] = @persona.errors.messages.first[1][0]
                    
                    format.html { redirect_to vendedor_cambiar_rol_path(persona: @persona.id)} 
                    format.json { render json: @persona.errors, status: :unprocessable_entity }
                else
                    format.html { render :new }
                    format.json { render json: @persona.errors, status: :unprocessable_entity }
                end
             end
  
    end
  end

  # POST /vendedors/actualizar_objetivos
  # Metodo para crear nuevos Objetivos Mensuales de un Vendedor o editar su valor (Ajax request)
  # Parametros: Mes, Anio, Vendedor, cantidad para cada Objetivo Mensual
  def actualizar_objetivos
    mes = params[:mes]
    anio = params[:anio]    
    @vendedor = Vendedor.find(params[:vendedor][:id])
    cantidad_op = params[:oportunidades]
    cantidad_pm = params[:pruebas_manejo]
    cantidad_v = params[:ventas]
    cantidad_f = params[:financiaciones]
    cantidad_c = params[:calidad]    
    tipo_objetivo_id = 7
    objetivo_op = ObjetivoMensual.find_by(mes: mes, anio: anio, vendedor_id: @vendedor.id, tipo_objetivo_id: tipo_objetivo_id)
    if cantidad_op.to_i == 0 and cantidad_pm.to_i == 0 and cantidad_v.to_i == 0 and cantidad_f.to_i == 0 and cantidad_c.to_i == 0
      msj = "No hay datos para actualizar"
    else
      msj = 'Se actualizaron los valores de '
    end
    @errores = Hash.new
    if cantidad_op.to_i != 0
      if objetivo_op != nil
        objetivo_op.cantidad_propuesta = cantidad_op
        if objetivo_op.save       
          msj += ' Oportunidades '
        else
          @errores[:oportunidades] = objetivo_op.errors.full_messages.first
        end
      else
        objetivo = ObjetivoMensual.new()
        objetivo.mes = mes
        objetivo.anio = anio
        objetivo.vendedor_id = @vendedor.id
        objetivo.punto_venta_id = @vendedor.punto_venta_id
        objetivo.tipo_objetivo_id = tipo_objetivo_id
        objetivo.user_id = current_user.id
        objetivo.cantidad_propuesta = cantidad_op
        if objetivo.save
          msj += ' Oportunidades '
        else
          @errores[:oportunidades] = objetivo.errors.full_messages.first
        end
      end
    end
    tipo_objetivo_id = 4
    objetivo_pm = ObjetivoMensual.find_by(mes: mes, anio: anio, vendedor_id: @vendedor.id, tipo_objetivo_id: tipo_objetivo_id)
    if cantidad_pm.to_i != 0 
      if objetivo_pm != nil
        objetivo_pm.cantidad_propuesta = cantidad_pm
        if objetivo_pm.save
          msj += ' Pruebas de manejo '
        else
          @errores[:pruebas_de_manejo] = objetivo_pm.errors.full_messages.first
        end
      else
        objetivo = ObjetivoMensual.new()
        objetivo.mes = mes
        objetivo.anio = anio
        objetivo.vendedor_id = @vendedor.id
        objetivo.punto_venta_id = @vendedor.punto_venta_id
        objetivo.tipo_objetivo_id = tipo_objetivo_id
        objetivo.user_id = current_user.id
        objetivo.cantidad_propuesta = cantidad_pm
        if objetivo.save
          msj += ' Pruebas de manejo '
        else
          @errores[:pruebas_de_manejo] = objetivo.errors.full_messages.first
        end
      end
    end
    tipo_objetivo_id = 5
    objetivo_v = ObjetivoMensual.find_by(mes: mes, anio: anio, vendedor_id: @vendedor.id, tipo_objetivo_id: tipo_objetivo_id)
    if cantidad_v.to_i != 0 
      if objetivo_v != nil
        objetivo_v.cantidad_propuesta = cantidad_v
        if objetivo_v.save
          msj += ' Ventas '
        else
          @errores[:ventas] = objetivo_v.errors.full_messages.first
        end
      else
        objetivo = ObjetivoMensual.new()
        objetivo.mes = mes
        objetivo.anio = anio
        objetivo.vendedor_id = @vendedor.id
        objetivo.punto_venta_id = @vendedor.punto_venta_id
        objetivo.tipo_objetivo_id = tipo_objetivo_id
        objetivo.user_id = current_user.id
        objetivo.cantidad_propuesta = cantidad_v
        if objetivo.save
          msj += ' Ventas '
        else
          @errores[:ventas] = objetivo.errors.full_messages.first
        end
      end
    end
    tipo_objetivo_id = 8
    objetivo_f = ObjetivoMensual.find_by(mes: mes, anio: anio, vendedor_id: @vendedor.id, tipo_objetivo_id: tipo_objetivo_id)
    if cantidad_f.to_i != 0 
      if objetivo_f != nil
        objetivo_f.cantidad_propuesta = cantidad_f
        if objetivo_f.save
          msj += ' Financiaciones '
        else
          @errores[:financiaciones] = objetivo_f.errors.full_messages.first
        end
      else
        objetivo = ObjetivoMensual.new()
        objetivo.mes = mes
        objetivo.anio = anio
        objetivo.vendedor_id = @vendedor.id
        objetivo.punto_venta_id = @vendedor.punto_venta_id
        objetivo.tipo_objetivo_id = tipo_objetivo_id
        objetivo.user_id = current_user.id
        objetivo.cantidad_propuesta = cantidad_f
        if objetivo.save
          msj += ' Financiaciones '
        else
          @errores[:financiaciones] = objetivo.errors.full_messages.first
        end
      end
    end
    tipo_objetivo_id = 3
    objetivo_c = ObjetivoMensual.find_by(mes: mes, anio: anio, vendedor_id: @vendedor.id, tipo_objetivo_id: tipo_objetivo_id)
    if cantidad_c.to_i != 0 
      if objetivo_c != nil
        objetivo_c.cantidad_propuesta = cantidad_c
        if objetivo_c.save
          msj += ' Calidad '
        else
          @errores[:calidad] = objetivo_c.errors.full_messages.first
        end
      else
        objetivo = ObjetivoMensual.new()
        objetivo.mes = mes
        objetivo.anio = anio
        objetivo.vendedor_id = @vendedor.id
        objetivo.punto_venta_id = @vendedor.punto_venta_id
        objetivo.tipo_objetivo_id = tipo_objetivo_id
        objetivo.user_id = current_user.id
        objetivo.cantidad_propuesta = cantidad_c
        if objetivo.save
          msj += ' Calidad '
        else
          @errores[:calidad] = objetivo.errors.full_messages.first
        end
      end
    end

    respond_to do |format|
      if @errores.blank?
        format.html { redirect_to @vendedor, notice: msj }
        format.json { head :no_content }
      else
        @bg_gray = true
        format.html { render :show }
        format.json { render json: @errores, status: :unprocessable_entity }
      end
    end    
  end

  # PATCH/PUT /vendedors/1
  # PATCH/PUT /vendedors/1.json
  def update
    respond_to do |format|
      if @vendedor.update(vendedor_params)
        format.html { redirect_to @vendedor, notice: 'Vendedor was successfully updated.' }
        format.json { render :show, status: :ok, location: @vendedor }
      else
        format.html { render :edit }
        format.json { render json: @vendedor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vendedors/1
  # DELETE /vendedors/1.json
  def destroy
    @vendedor.dar_baja(Date.today)
    respond_to do |format|
      format.html { redirect_to vendedors_url, notice: 'Se dio de baja correctamente.' }
      format.json { head :no_content }
    end
  end

  # GET  /home_vendedor
  # Metodo que renderiza el layout del home para el usuario con rol vendedor y punto_venta
  # Si el usuario actual tiene el rol vendedor se muestran los datos referidos a su carga y la posibilidad de abrir
  # un modal para ingresar la carga diaria
  # Si el usuario actual tiene el rol punto_venta se muestra un desplegable con los vendedores con la posibilidad
  # de seleccionar uno y ver su carga
  def home
    @sidebar = false
    @footer = false
    @carga_diarium = CargaDiarium.new
    @tipos_objetivos = TipoObjetivo.where(tipo: 'KPI')
    if current_user.has_role? :vendedor and !(current_user.has_role? :punto_venta) 
      @vendedor = current_user.persona.vendedors.first
    else
      if (current_user.has_role? :punto_venta) && (!params[:vendedor].nil?) && (params[:vendedor] != "Mis datos como vendedor" )
        @vendedor = Vendedor.find_by(numero: params[:vendedor], punto_venta_id: current_user.punto_venta_id)
      else
        @vendedor = current_user.persona.vendedors.first
      end
    end
  end

  # POST /objetivos_y_carga_diaria
  # Metodo para mostrar el valor de los Objetivos Mensuales asignados a un Vendedor en cada mes de cada anio (Ajax request)
  # Parametros: Mes, anio, vendedor
  def objetivos_y_carga_diaria
    mes = params[:mes].to_i
    anio = params[:anio].to_i
    vendedor_id = params[:vendedor_id].to_i
    vendedor = Vendedor.find(vendedor_id)
    totales = Hash.new
    total_ob_op = ObjetivoMensual.total_objetivos_punto_venta(anio, mes, vendedor, 7)
    total_ob_pm = ObjetivoMensual.total_objetivos_punto_venta(anio, mes, vendedor, 4)
    total_ob_v = ObjetivoMensual.total_objetivos_punto_venta(anio, mes, vendedor, 5)
    total_ob_csi = ObjetivoMensual.total_objetivos_punto_venta(anio, mes, vendedor, 3)
    total_ob_fin = ObjetivoMensual.total_objetivos_punto_venta(anio, mes, vendedor, 8)
    total_op = ObjetivoMensual.asignado_o_proyeccion(anio, mes, vendedor, 7)
    total_pm = ObjetivoMensual.asignado_o_proyeccion(anio, mes, vendedor, 4)
    total_v = ObjetivoMensual.asignado_o_proyeccion(anio, mes, vendedor, 5)
    total_csi = ObjetivoMensual.asignado_o_proyeccion(anio, mes, vendedor, 3)
    total_fin = ObjetivoMensual.asignado_o_proyeccion(anio, mes, vendedor, 8)
    totales[:ob_oportunidades] = total_ob_op
    totales[:ob_pruebas_manejo] = total_ob_pm
    totales[:ob_ventas] = total_ob_v
    totales[:ob_csi] = total_ob_csi
    totales[:ob_fin] = total_ob_fin
    totales[:oportunidades] = total_op
    totales[:pruebas_manejo] = total_pm
    totales[:ventas] = total_v
    totales[:calidad] = total_csi
    totales[:financiaciones] = total_fin
    render json: totales.to_json
  end

  # GET /vendedor/cambiar_rol
  def cambiar_rol
      @persona = Persona.where(id: params[:persona]).first
      @vendedor = Vendedor.new
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vendedor
      @vendedor = Vendedor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vendedor_params
      params.require(:vendedor).permit(:foto, :numero, :fecha_alta, :fecha_baja, :persona_id, :punto_venta_id)
    end

    def persona_params
      params.require(:persona).permit(:tipo_documento_id, :numero_documento, :cuit, :apellido, :nombre, :domicilio, :telefono, :email, :fecha_nacimiento)
    end
end
