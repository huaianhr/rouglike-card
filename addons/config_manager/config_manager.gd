@tool
extends EditorPlugin

var config_panel_instance

func _enter_tree():
	# 创建配置面板实例
	var config_panel_scene = preload("res://addons/config_manager/ui/config_panel.tscn")
	config_panel_instance = config_panel_scene.instantiate()
	
	# 添加到编辑器底部面板
	add_control_to_bottom_panel(config_panel_instance, "配置管理器")
	
	print("[配置管理器插件] 已加载")

func _exit_tree():
	# 清理
	if config_panel_instance:
		remove_control_from_bottom_panel(config_panel_instance)
		config_panel_instance.queue_free()
	
	print("[配置管理器插件] 已卸载")
