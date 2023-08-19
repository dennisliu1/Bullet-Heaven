extends Button

signal click_end()

func _on_audio_click_finished():
	$AudioClick.play()

func _on_mouse_entered():
	$AudioHover.play()


func _on_pressed():
	emit_signal("click_end")


