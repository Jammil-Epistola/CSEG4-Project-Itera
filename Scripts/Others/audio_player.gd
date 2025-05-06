extends AudioStreamPlayer

const MENU_MUSIC = preload("res://Assets/BGMS/Art of Silence.mp3")
const GAME_MUSIC = preload("res://Assets/BGMS/Fall Moon.mp3")  # Replace this

@export var fade_duration := 1.5  # Seconds

var _target_stream: AudioStream = null
var _target_volume_db := 0.0
var _fade_timer := 0.0
var _is_fading := false
var _fade_direction := 1  # 1 = fade in, -1 = fade out

func _ready():
	bus = "Music"
	volume_db = 0.0

func play_menu_music():
	_request_music(MENU_MUSIC)

func play_game_music():
	_request_music(GAME_MUSIC)

func stop_music():
	_is_fading = false
	stop()

# Internal: Request a music transition
func _request_music(new_stream: AudioStream, volume := 0.0):
	if stream == new_stream:
		return
	_target_stream = new_stream
	_target_volume_db = volume
	_fade_direction = -1  # Start by fading out current track
	_fade_timer = fade_duration
	_is_fading = true

# Called every frame for volume transitions
func _process(delta):
	if _is_fading:
		_fade_timer -= delta
		var t: float = clamp(1.0 - float(_fade_timer) / float(fade_duration), 0.0, 1.0)


		if _fade_direction == -1:
			# Fade out current music
			volume_db = lerp(0.0, -40.0, t)
			if _fade_timer <= 0.0:
				# Switch to target stream and start fading in
				stream = _target_stream
				play()
				_fade_timer = fade_duration
				_fade_direction = 1
		elif _fade_direction == 1:
			# Fade in target music
			volume_db = lerp(-40.0, _target_volume_db, t)
			if _fade_timer <= 0.0:
				volume_db = _target_volume_db
				_is_fading = false
