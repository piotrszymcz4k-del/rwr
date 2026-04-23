extends XRController3D

@onready var ray: RayCast3D = $TeleportRay
@onready var marker: MeshInstance3D = $TeleportMarker
var xr_origin: XROrigin3D
var xr_camera: XRCamera3D

func _ready() -> void:
	xr_origin = get_parent() as XROrigin3D
	xr_camera = xr_origin.get_node("XRCamera3D") as XRCamera3D
	marker.visible = false
	
	# TA LINIJKA NASŁUCHUJE KLIKNIĘCIA PRZYCISKU:
	self.button_pressed.connect(self._on_button_pressed)

func _process(_delta: float) -> void:
	if ray.is_colliding():
		marker.global_transform.origin = ray.get_collision_point()
		marker.visible = true
	else:
		marker.visible = false

# TA FUNKCJA ODPALA TELEPORT PO KLIKNIĘCIU SPUSTU:
func _on_button_pressed(button_name: String) -> void:
	if button_name == "trigger_click" or button_name == "trigger":
		teleport_now()

func teleport_now() -> void:
	if not ray.is_colliding():
		return
	var target: Vector3 = ray.get_collision_point()

	var origin_tf := xr_origin.global_transform
	var cam_tf := xr_camera.global_transform
	var cam_offset := cam_tf.origin - origin_tf.origin

	cam_offset.y = 0.0
	origin_tf.origin = Vector3(target.x - cam_offset.x, target.y, target.z - cam_offset.z)
	xr_origin.global_transform = origin_tf
