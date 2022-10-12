extends RayCast2D

var is_casting := false setget set_is_casting

func _ready() -> void:
	set_physics_process(false)
	self.is_casting = true
	$Line2D.points[1] = Vector2.ZERO

#func _unhandled_input(event: InputEvent) -> void:
#		if event is InputEventMouseButton:
#			self.is_casting = event.pressed


func _physics_process(delta: float) -> void:
	var cast_point := cast_to
	force_raycast_update()
	
	$CollisionParticle2D.emitting = is_colliding()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		$CollisionParticle2D.global_rotation = get_collision_normal().angle()
		$CollisionParticle2D.position = cast_point
	
	
	$Line2D.points[1] = cast_point
	$BeamParticle2D.position = cast_point * 0.5
	$BeamParticle2D.emission_rect_extents.x = cast_point.length() * 0.5
	if get_collider() != null:
		if "Player" in get_collider().name:
			get_collider().damage(10)

func set_is_casting(cast: bool) -> void:
	is_casting = cast
	
	$BeamParticle2D.emitting = is_casting
	$CastingParticle2D.emitting = is_casting
	if is_casting:
		appear()
	else:
		$CollisionParticle2D.emitting = false
		disappear()
	set_physics_process(is_casting)


func appear() -> void:
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 0, 10.0, 0.2)
	$Tween.start()

func disappear() -> void:
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 10.0, 0, 0.1)
	$Tween.start()
	
