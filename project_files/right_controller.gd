extends XRController3D

@onready var ray: RayCast3D = $TeleportRay
@onready var marker: MeshInstance3D = $TeleportMarker
var xr_origin: XROrigin3D
var xr_camera: XRCamera3D

# Zmienne do obrotu skokowego (Snap Turn)
var turn_step: float = deg_to_rad(15.0) # Obrót o 15 stopni
var can_snap_turn: bool = true # Blokada ciągłego obrotu

func _ready() -> void:
	xr_origin = get_parent() as XROrigin3D
	xr_camera = xr_origin.get_node("XRCamera3D") as XRCamera3D
	marker.visible = false
	
	# Podłączenie przycisku - teleport nastąpi przy PUSZCZENIU triggera
	self.button_released.connect(self._on_button_released)

func _process(_delta: float) -> void:
	# 1. OBSŁUGA ZNACZNIKA TELEPORTU
	if ray.is_colliding():
		marker.global_position = ray.get_collision_point()
		marker.visible = true
	else:
		marker.visible = false
		
	# 2. OBSŁUGA OBROTU SKOKOWEGO (Prawy joystick)
	var joystick: Vector2 = get_vector2("thumbstick")
	if abs(joystick.x) > 0.5: # Wychylenie powyżej 50%
		if can_snap_turn:
			snap_turn(sign(joystick.x))
			can_snap_turn = false # Blokujemy kolejne obrócenie
	elif abs(joystick.x) < 0.2: # Puszczenie drążka
		can_snap_turn = true # Odblokowujemy obrót

func _on_button_released(button_name: String) -> void:
	if button_name == "trigger_click" or button_name == "trigger":
		teleport_now()

func snap_turn(direction: float) -> void:
	# Obrót uwzględniający offset głowy (kamera zostaje w miejscu)
	var cam_pos = xr_camera.global_position
	xr_origin.rotate_y(-direction * turn_step)
	var new_cam_pos = xr_camera.global_position
	xr_origin.global_position += (cam_pos - new_cam_pos)

func teleport_now() -> void:
	if not ray.is_colliding():
		return
		
	var target: Vector3 = ray.get_collision_point()
	var origin_pos := xr_origin.global_position
	var cam_pos := xr_camera.global_position
	
	# Obliczamy wektor przesunięcia między środkiem pokoju a głową (offset)
	var cam_offset := cam_pos - origin_pos
	
	# Ignorujemy pozycję na osi Y, żeby gracz nie zapadł się pod ziemię lub nie lewitował
	cam_offset.y = 0.0 
	
	# Ustalamy nową pozycję: celujemy głową w target, więc środek pokoju musi być przesunięty o offset
	xr_origin.global_position = Vector3(target.x - cam_offset.x, target.y + 0.02, target.z - cam_offset.z)
