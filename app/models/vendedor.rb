class Vendedor < ApplicationRecord
  #Relaciones
  belongs_to :persona
  belongs_to :punto_venta, :foreign_key => 'punto_venta_id', :class_name => 'PuntoVentum'
  has_many :estado_personas

  #Validaciones relacionadas con el archivo adjunto
  #validates_attachment_presence :foto
  has_attached_file :foto, styles: { medium: "200x250>", thumb: "100x100#" }, default_url: "/assets/:style/missing.png"
  validates_attachment_content_type :foto, content_type: /\Aimage/
  validates_attachment :foto, content_type: { content_type: ['image/jpeg', 'image/png', 'image/jpg'] } 
  validates_attachment_size :foto, less_than_or_equal_to: 4.megabytes

  #Validaciones del modelo
  validates :numero, :uniqueness => {:message => "Alias debe ser único"}
  validates :numero, :presence => { :message => "Ya existe un vendedor con ese alias, asignarle otro alias." }
  validates :fecha_alta, :presence => { :message => "Debe completar el campo Fecha" }
  validate :control_persona,  on: :create

  validate :max_vendedor

  before_create :habilitar_user
  before_update :deshabilitar_user

  #Valida la cantidad maxima de vendedor por punto de venta
  def max_vendedor
    pv = self.punto_venta
    cantVend = pv.concesionaria.cantVend
    cantvendconc = Vendedor.where(:id => pv.id).count

    if (cantVend.to_i <= cantvendconc.to_i + 1 )
      errors.add(:base, "No puede crear mas Vendedores para este punto de venta, solicite permiso")
    end
  end

  def to_s
  	"#{self.numero} - #{self.persona.apellido}, #{self.persona.nombre}"
  end

  def control_persona

    if ((Vendedor.where(:persona_id => self.persona.id, :punto_venta_id => self.punto_venta_id).first) != nil)
       errors.add(:base, "Esta persona ya se encuentra como vendedor en este punto de venta")
    end
  end

  #Baja logica, vendedor
  def dar_baja(fecha)
    self.update(fecha_baja: fecha, baja: true)
  end

  #Controles para navegacion por vendedor
  def next
    self.class.where("id > ?", id).where(:punto_venta_id => self.punto_venta_id).first
  end

  #Controles para navegacion por vendedor
  def previous
    self.class.where("id < ?", id).where(:punto_venta_id => self.punto_venta_id).last
  end


  def habilitar_user
  
    usuario = User.new(email: self.persona.email, password: "12345678", persona_id: self.persona.id, punto_venta_id: self.punto_venta_id, concesionaria_id: self.punto_venta.concesionaria_id)
    if usuario.save
      usuario.add_role("vendedor")
    else
      usuario = User.where(email: self.persona.email).first
      usuario.update(punto_venta_id: self.punto_venta_id, concesionaria_id: self.punto_venta.concesionaria_id)
      usuario.add_role("vendedor")
    end
  end

  def deshabilitar_user
    if self.baja
      usuario = User.where(email: self.persona.email).first
      usuario.remove_role("vendedor")
    end
  end

end
