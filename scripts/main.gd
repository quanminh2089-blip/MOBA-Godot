extends Node3D

var camera: Camera3D
var focus := Vector3.ZERO
var zoom := 10.0
var dragging := false
var last_touch := Vector2.ZERO
var finger := -1
var hud: Label
var model: Node3D

func _ready() -> void:
    var scene := load("res://assets/1V1.glb") as PackedScene
    if scene == null:
        push_error("Khong tai duoc model 1V1.glb")
        return
    model = scene.instantiate() as Node3D
    add_child(model)
    camera = Camera3D.new()
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.current = true
    add_child(camera)
    var sunlight := DirectionalLight3D.new()
    sunlight.rotation_degrees = Vector3(-55, -25, 0)
    sunlight.light_energy = 1.2
    add_child(sunlight)
    var env := WorldEnvironment.new()
    var e := Environment.new()
    e.background_mode = Environment.BG_COLOR
    e.background_color = Color("263b35")
    e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    e.ambient_light_color = Color.WHITE
    e.ambient_light_energy = 0.75
    env.environment = e
    add_child(env)
    _fit_map()
    _make_ui()
    _update_camera()

func _fit_map() -> void:
    var bounds := AABB()
    var has_bounds := false
    for child in model.find_children("*", "MeshInstance3D", true, false):
        var mesh_node := child as MeshInstance3D
        if mesh_node.mesh == null:
            continue
        var local_box := mesh_node.get_aabb()
        for x in [0, 1]:
            for y in [0, 1]:
                for z in [0, 1]:
                    var corner := local_box.position + local_box.size * Vector3(x,y,z)
                    var point := mesh_node.global_transform * corner
                    if not has_bounds:
                        bounds = AABB(point, Vector3.ZERO)
                        has_bounds = true
                    else:
                        bounds = bounds.expand(point)
    if has_bounds:
        focus = bounds.get_center()
        zoom = maxf(bounds.size.x, bounds.size.z) * 1.25
        zoom = maxf(zoom, 3.0)

func _update_camera() -> void:
    if camera == null: return
    camera.size = zoom
    camera.position = focus + Vector3(0, zoom * 1.2, zoom * 0.7)
    camera.look_at(focus, Vector3.UP)

func _make_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var control := Control.new()
    control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    control.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(control)
    hud = Label.new()
    hud.text = "MOBA 1V1  |  Vuot de di chuyen camera  |  +/- de zoom"
    hud.position = Vector2(22, 18)
    hud.add_theme_font_size_override("font_size", 23)
    hud.add_theme_color_override("font_color", Color.WHITE)
    control.add_child(hud)
    var plus := _make_button(control, "+", -155)
    plus.pressed.connect(func(): zoom = maxf(zoom * 0.8, 1.0); _update_camera())
    var minus := _make_button(control, "−", -80)
    minus.pressed.connect(func(): zoom = minf(zoom * 1.25, 2000.0); _update_camera())

func _make_button(parent: Control, label_text: String, right_offset: float) -> Button:
    var b := Button.new()
    b.text = label_text
    b.add_theme_font_size_override("font_size", 35)
    b.anchor_left = 1.0
    b.anchor_right = 1.0
    b.anchor_top = 1.0
    b.anchor_bottom = 1.0
    b.offset_left = -100
    b.offset_right = -20
    b.offset_top = right_offset - 65
    b.offset_bottom = right_offset
    parent.add_child(b)
    return b

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and finger == -1:
            finger = event.index
            last_touch = event.position
            dragging = true
        elif not event.pressed and event.index == finger:
            finger = -1
            dragging = false
    elif event is InputEventScreenDrag and dragging and event.index == finger:
        _pan(event.relative)
    elif event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            dragging = event.pressed
            last_touch = event.position
        elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
            zoom = maxf(zoom * 0.9, 1.0)
            _update_camera()
        elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            zoom *= 1.1
            _update_camera()
    elif event is InputEventMouseMotion and dragging:
        _pan(event.relative)

func _pan(delta: Vector2) -> void:
    var scale_factor := zoom / maxf(get_viewport().get_visible_rect().size.y, 1.0)
    var right := camera.global_transform.basis.x
    var forward := Vector3(camera.global_transform.basis.y.x, 0, camera.global_transform.basis.y.z).normalized()
    focus -= right * delta.x * scale_factor
    focus += forward * delta.y * scale_factor
    _update_camera()
