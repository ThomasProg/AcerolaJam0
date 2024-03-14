extends Control
class_name Credits

signal onResume()

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_rich_text_label_2_meta_clicked(meta):
	OS.shell_open(str(meta))


func _on_button_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	queue_free()
	onResume.emit()
