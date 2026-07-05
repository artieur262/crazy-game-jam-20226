extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


const SPEED = 150.0
var avancement: float = 0
var step := 0
var max_zoom = 10
var min_zoom = 1
@export var raycast: RayCast2D

func _ready() -> void:
	raycast.collision_mask |= Interactif.mask
	mettre_a_jour_console()

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var directionX := Input.get_axis("left", "right")
	if directionX:
		velocity.x = directionX * SPEED
		if directionX > 0:
			animated_sprite_2d.play("walk_right")
			$RayCast2D.rotation = deg_to_rad(90)
		else:
			animated_sprite_2d.play("walk_left")
			$RayCast2D.rotation = deg_to_rad(-90)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite_2d.play("idle")
	var directionY := Input.get_axis("up", "down")
	if directionY:
		velocity.y = directionY * SPEED
		if directionY > 0:
			animated_sprite_2d.play("walk_down")
			$RayCast2D.rotation = deg_to_rad(180)
		else:
			animated_sprite_2d.play("walk_up")
			$RayCast2D.rotation = deg_to_rad(0)
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	move_and_slide()
	if raycast.is_colliding():
		step = 0
		var collider := raycast.get_collider() as Interactif
		if Input.is_action_pressed("interact"):
			avancement += delta
			$Label.visible = false
			$ProgressBar.visible = true
			$ProgressBar.value = avancement/collider.temp*100
			if avancement >= collider.temp:
				collected(collider.collect())
				avancement = 0
		else:
			avancement = 0
			$Label.visible = true
			$ProgressBar.visible = false
	elif step == 0:
		step = 1
		avancement = 0
		$Label.visible = false
		$ProgressBar.visible = false
		
func _input(event: InputEvent) -> void:
	if event.is_action("zoom"):
		$Camera2D.zoom = Vector2.ONE * clamp($Camera2D.zoom.x + 0.3, min_zoom, max_zoom)
		mettre_a_jour_console()
	elif event.is_action("dezoom"):
		$Camera2D.zoom = Vector2.ONE * clamp($Camera2D.zoom.x - 0.3, min_zoom, max_zoom)
		mettre_a_jour_console()

func mettre_a_jour_console():
	var taille = get_viewport_rect().size/$Camera2D.zoom
	var i = 1/$Camera2D.zoom.x
	$Notifs.scale = Vector2(i,i)
	$Notifs.position.x = -taille.x/2+1


func collected(items: Dictionary[Item, int]):
	var text := RichTextLabel.new()
	text.text = "Obtenus:\n"
	var timer := Timer.new()
	timer.wait_time = 3
	for item in items:
		var quantite := items[item]
		text.text += "qeeeee%s (%d)\n" % [item.nom,quantite]
	text.text = text.text.left(-1)
	text.add_child(timer)
	text.fit_content = true
	$Notifs.add_child(text)
	timer.timeout.connect(text.queue_free)
	timer.timeout.connect(timer.queue_free)
	timer.start()
	# TODO: ajouter à l'inventaire
