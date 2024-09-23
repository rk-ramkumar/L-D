extends Node


func _notification(what):
	match what:
		NOTIFICATION_WM_GO_BACK_REQUEST:
			get_tree().root.get_node("ExitPopup").visible = true
