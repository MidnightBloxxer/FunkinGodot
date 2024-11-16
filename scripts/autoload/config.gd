extends Node

var version_suffix = "-indev"

var file := ConfigFile.new()
var first_launch: bool = false

signal value_changed(section: String, key: String, value: Variant)


func _ready() -> void:
	file = _parse_default_as_config()
	_load_user_config()
	save()


func save() -> void:
	file.save('user://config.cfg')


func get_value(section: String, key: String) -> Variant:
	return file.get_value(section, key)


func set_value(section: String, key: String, value: Variant, autosave: bool = true) -> void:
	file.set_value(section, key, value)
	value_changed.emit(section, key, value)
	
	if autosave:
		save()


func _load_user_config() -> Error:
	if FileAccess.file_exists('user://config.cfg'):
		var user_cfg := ConfigFile.new()
		var error := user_cfg.load('user://config.cfg')
		if error != OK:
			push_error('Config could not be loaded with error code %s!' % error)
			return error
		
		for section: String in user_cfg.get_sections():
			for key: String in user_cfg.get_section_keys(section):
				if file.has_section_key(section, key):
					file.set_value(section, key, user_cfg.get_value(section, key))
		
		return OK
	
	first_launch = true
	return ERR_FILE_NOT_FOUND


func _parse_default_as_config() -> ConfigFile:
	var new_file := ConfigFile.new()
	
	for section: String in default_configuration.keys():
		var section_value: Dictionary = default_configuration.get(section, {})
		for key: String in section_value.keys():
			new_file.set_value(section, key, section_value.get(key, null))
	
	return new_file


var default_configuration: Dictionary = {
	'gameplay': {
		'scroll_direction': 'up',
		'centered_receptors': false,
		'manual_offset': 0.0,
		'scroll_speed_method': 'chart_based',
		'custom_scroll_speed': 1.0,
		'binds': {
			'left': KEY_D,
			'down': KEY_F,
			'up': KEY_J,
			'right': KEY_K,
		},
	},
	'sound': {
		'buses': {
			'Master': 50.0,
			'Music': 100.0,
			'SFX': 100.0,
		},
		'bus_effects': {
			'Master': {
				'hardlimiter': {
					'ceiling': -6.0,
					'pre_gain': -12.0,
					'release': 0.1,
					'enabled': false,
				},
			},
			'Music': {},
			'SFX': {},
		},
		'recalculate_output_latency': true,
	},
	'interface': {
		'sustain_layer': 'below',
		'cpu_strums_press': true,
		'note_splash_alpha': 60.0,
		'countdown_on_resume': false,
	},
	'performance': {
		'quality': 'default',
		'scene_transitions': 'default',
		'fps_cap': -1,
		'vsync_mode': 'disabled',
		'auto_pause': false,
		'performance_info': 'default',
		'threaded_note_spawning': true,
		'preload_notes': false,
		'performance_info_visible': false,
	},
	'accessibility': {
		'flashing_lights': true,
		'locale': 'en',
	},
}
