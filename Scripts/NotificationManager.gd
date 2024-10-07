extends Node


func _notification(what):
	match what:
		NOTIFICATION_WM_GO_BACK_REQUEST:
			if !get_tree().root.has_node("ExitPopup"):
				get_tree().quit()
				return
			get_tree().root.get_node("ExitPopup").handle_back_request()

func back_request(screen_name):
	get_tree().root.get_node("ExitPopup").handle_back_request(screen_name)
