extends Node

var config = ConfigFile.new()

var VIDEO_SECTION = "video"
var VIDEO_RESOLUTION = "resolution"
var VIDEO_FULLSCREEEN = "fullscreen"
var VIDEO_VSYNC = "vsync"

func init_settings():
	var settings = {
		VIDEO_RESOLUTION: Vector2(640, 360),
		VIDEO_FULLSCREEEN: false,
		VIDEO_VSYNC: false,
	}
	return settings

func save_settings(settings):
	# Store the values.
	## Video settings
	config.set_value(VIDEO_SECTION, VIDEO_RESOLUTION, settings.resolution)
	config.set_value(VIDEO_SECTION, VIDEO_FULLSCREEEN, settings.fullscreen)
	config.set_value(VIDEO_SECTION, VIDEO_VSYNC, settings.vsync)
	
	# Save the data into a file, overwrite the file if it already exists.
	config.save("user://user_config.cfg")

func load_settings():
	var err = config.load("user://user_config.cfg")

	# If the file didn't load, ignore it.
	if err != OK:
		return init_settings
	
	var settings = {}
	# Set the data
	## Video section
	settings.resolution = config.get_value(VIDEO_SECTION, VIDEO_RESOLUTION)
	settings.fullscreen = config.get_value(VIDEO_SECTION, VIDEO_FULLSCREEEN)
	settings.vsync = config.get_value(VIDEO_SECTION, VIDEO_VSYNC)
	return settings


func update_settings(settings: Dictionary):
	get_window().size = settings.resolution
	DisplayServer.window_set_vsync_mode(settings.vsync)
	if settings.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	pass
