class_name NumberOption extends Option


@export var section: StringName = &'gameplay'
@export var key: StringName = &'manual_offset'

@export var integers: bool = true
@export var ranged: bool = false

@export var minimum: float = -10.0
@export var maximum: float = 10.0
@export var step: float = 1.0
@export var value_suffix: StringName = &''

@export var increment_delay: float = 0.1
@export var root: Node

@onready var value_label: Alphabet = $value

var timer: float = 0.0
var value: float = 0.0:
	set(new_value):
		var final_value = new_value if not integers else int(new_value)
		Config.set_value(section, key, final_value)
		value = new_value
		
		if integers:
			value_label.text = '< %s%s >' % [final_value, value_suffix]
		else:
			value_label.text = '< %s%s >' % [str(snapped(final_value, step)).pad_decimals(1), value_suffix]


func _ready() -> void:
	value = Config.get_value(section, key)
	
	if not is_instance_valid(root): 
		root = get_parent().get_parent()


func _select() -> void:
	selected = not selected
	root.active = not selected
	GlobalAudio.get_player('MENU/CONFIRM').play()


func _process(delta: float) -> void:
	if not selected:
		return
	
	var axis: float = Input.get_axis('ui_left', 'ui_right')
	if axis == 0.0:
		timer = 0.0
		return
	
	if Input.is_action_just_pressed('ui_left') or Input.is_action_just_pressed('ui_right'):
		timer = increment_delay
	
	timer += delta
	
	var delay_modifier: float = 1.0 + \
			float(Input.is_action_pressed('shift')) +\
			float(Input.is_action_pressed('alt')) * 3.0
	if timer >= increment_delay / delay_modifier:
		timer = 0.0
		
		if ranged:
			value = clampf(value + axis * step, minimum, maximum)
		else:
			value += axis * step


func _input(event: InputEvent) -> void:
	if not selected:
		return
	if not event.is_pressed():
		return
	if event.is_echo():
		return
	
	if event.is_action('ui_accept') or event.is_action('ui_cancel'):
		get_viewport().set_input_as_handled()
		_select()
