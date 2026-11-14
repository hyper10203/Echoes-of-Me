extends Node2D
## One reusable room, driven by the ten small records below. Art is intentionally
## drawn in code so every placeholder is original, editable, and self-contained.

const VIEW_W := 960.0
const H := 540.0
const LEVEL_W := 2880.0
const FLOOR_Y := 470.0
const ANCHOR_X := 260.0
const MEMORY_X := 515.0
const EXIT_X := 2810.0
const GRAVITY := 1180.0
const MOVE_SPEED := 290.0
const ACCEL := 1900.0
const FRICTION := 2200.0
const PuzzleDisplayScript := preload("res://scripts/puzzle_display.gd")
const VignetteScript := preload("res://scripts/vignette.gd")
const LEVELS := [
	{"place":"RAIN PORCH", "action":"Wake the porch bell", "clue":"A note in a child's hand: ‘If the bell rings twice, answer the second one.’ The handwriting is yours.", "next":"The corridor answers with a second note.", "accent":Color("78d7d2"), "icon":"bell", "kind":"rope", "mechanic":"WIND THE ROPE", "tier":1, "challenge":"A steady first crossing", "puzzle":"chime", "solution":[], "hint":"Wait for the white hand to pass through the warm gold arc."},
	{"place":"BELL CORRIDOR", "action":"Catch the returning clapper", "clue":"The second note repeats your first exactly—even the little breath before it.", "next":"The echo has led you to the nursery.", "accent":Color("f2bd74"), "icon":"clapper", "kind":"clapper", "mechanic":"CATCH THE ECHO", "tier":2, "challenge":"One launch, one landing", "puzzle":"echo", "solution":[], "hint":"Each pale ring reaches the center once. Answer only when the pulse is bright."},
	{"place":"WEST NURSERY", "action":"Set the moon hooks", "clue":"Two chalk girls, one pair of shoes. The second outline is drawn in a mirror.", "next":"The lift log is still pinned below.", "accent":Color("ef9db7"), "icon":"moon", "kind":"moons", "mechanic":"HANG THE MOON", "tier":3, "challenge":"Small platforms; precise jumps", "puzzle":"moon", "solution":[1, 3, 2], "hint":"The mirror reverses left and right. Set the crescent tips to face the reflected chalk moons."},
	{"place":"LAUNDRY LIFT", "action":"Balance the counterweight", "clue":"The lift ledger records one passenger: Mara Vale, age eight. The return box is blank.", "next":"A brass name tag glints beneath the cistern water.", "accent":Color("a9b8e8"), "icon":"weight", "kind":"lift", "mechanic":"RIDE THE LIFT", "tier":3, "challenge":"A slow ride gives you time to learn", "puzzle":"weights", "solution":[1, 2, 3], "hint":"The stamped weights progress light, middle, heavy: one block, two blocks, three blocks."},
	{"place":"CISTERN RIM", "action":"Route the drained water", "clue":"The tag reads FOUND ALIVE, 8:17. Someone crossed out the word ‘missing.’", "next":"Mother's greenhouse diary is upstairs.", "accent":Color("76d2ad"), "icon":"wheel", "kind":"sluice", "mechanic":"LOWER THE WATER", "tier":4, "challenge":"Narrow, uneven stepping stones", "puzzle":"pipes", "solution":[1, 3, 2], "hint":"Follow the carved arrows: first turns down, middle turns left, last turns up."},
	{"place":"GLASSHOUSE", "action":"Aim the broken sunlight", "clue":"Mother wrote: ‘Mara asks if the bell can talk. It only repeats what enters it.’", "next":"Every clock in the house is stopped at 8:17.", "accent":Color("b8d986"), "icon":"prism", "kind":"light", "mechanic":"FOLLOW THE LIGHT", "tier":4, "challenge":"Wide one-way ledges; no rush", "puzzle":"light", "solution":[2, 0, 3], "hint":"The foliage marks the path: east, north, west. Match each mirror's bright edge to that direction."},
	{"place":"CLOCK ROOM", "action":"Restore 08:17", "clue":"The maintenance log says the bell's low note continued after the final strike. A perfect echo.", "next":"The rescue report is filed in the flood archive.", "accent":Color("e4a975"), "icon":"gear", "kind":"gears", "mechanic":"TIME THE GEARS", "tier":5, "challenge":"Quick gears move out of phase", "puzzle":"clock", "solution":[8, 17], "hint":"The found-alive tag gave the house time. The smaller hand wants 8; the long hand wants 17."},
	{"place":"FLOOD ARCHIVE", "action":"Rebuild the report", "clue":"The rescue report: Mara Vale, eight years old, found alive downstream at 8:17.", "next":"The original recording is below the house.", "accent":Color("82bed6"), "icon":"page", "kind":"stairs", "mechanic":"STACK THE SHELVES", "tier":5, "challenge":"A recovery climb with clear steps", "puzzle":"archive", "solution":[2, 3, 1, 0], "hint":"The cards are shuffled. Reconstruct the timeline: alarm, search, rescue, report."},
	{"place":"UNDERCROFT", "action":"Repeat the signal relay", "clue":"On the tape, child-Mara says: ‘I hear you twice. Is one of us the echo?’ Then the same breath, older.", "next":"The bell can only answer once more.", "accent":Color("d19be8"), "icon":"lamp", "kind":"pulse", "mechanic":"CROSS ON THE BEAT", "tier":6, "challenge":"A short signal window; wait for the glow", "puzzle":"signal", "solution":[1, 3, 0, 2, 3, 1], "hint":"Use H to replay the relay. Its rhythm is six lights, not a speed test."},
	{"place":"BELL TOWER", "action":"Align the last resonance", "clue":"There was never another girl. The past and present are the same 8:17, heard twice: Mara's memory and the bell's echo. She survived. The voice calling her home is her own.", "next":"", "accent":Color("f2d486"), "icon":"clapper", "kind":"rings", "mechanic":"FOLLOW YOUR OWN VOICE", "tier":7, "challenge":"Three fast, narrow moving rings", "puzzle":"resonance", "solution":[3, 1, 0, 2, 1, 3, 0], "hint":"‘Answer the second one.’ Replay the remembered signal backwards; the bell comes last."}
]

var mode := "title" # title, playing, puzzle, journal, paused, ending
var level_index := 0
var repaired: Array[bool] = []
var journal: Array[String] = []
var journal_index := 0
var anchor_active := false
var is_past := false
var player: CharacterBody2D
var camera: Camera2D
var world: Node2D
var ui: CanvasLayer
var fx_layer: CanvasLayer
var vignette: Control
var title_label: Label
var subtitle_label: Label
var hud_label: Label
var era_label: Label
var challenge_label: Label
var prompt_label: Label
var story_label: Label
var story_title_label: Label
var overlay_label: Label
var journal_title_label: Label
var journal_list_label: Label
var journal_detail_label: Label
var journal_hint_label: Label
var puzzle_title_label: Label
var puzzle_body_label: Label
var puzzle_hint_label: Label
var puzzle_status_label: Label
var puzzle_controls_label: Label
var puzzle_display: Control
var journal_panel: Panel
var title_panel: Panel
var hud_panel: Panel
var era_panel: Panel
var progress_track: Panel
var progress_fill: Panel
var story_panel: Panel
var prompt_panel: Panel
var pause_panel: Panel
var puzzle_panel: Panel
var last_bounce_ms := 0
var story_time := 0.0
var story_text := ""
var room_time := 0.0
var movers: Array[Dictionary] = []
var bounce_pads: Array[float] = []
var pulse_shape: CollisionShape2D
var pulse_period := 3.6
var pulse_window := 2.55
var puzzle_cursor := 0
var puzzle_values: Array[int] = []
var puzzle_input: Array[int] = []
var puzzle_timer := 0.0
var puzzle_stage := 0
var puzzle_attempts := 0
var puzzle_reveal_time := 0.0
var puzzle_feedback := ""
var puzzle_hint_visible := false


func _ready() -> void:
	for _i in LEVELS.size():
		repaired.append(false)
	_build_actor()
	_build_ui()
	_refresh_room()
	_update_screen()


func _build_actor() -> void:
	world = Node2D.new()
	world.name = "RoomGeometry"
	add_child(world)
	player = CharacterBody2D.new()
	player.name = "Mara"
	player.position = Vector2(74, 430)
	var hitbox := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(22, 38)
	hitbox.shape = shape
	player.add_child(hitbox)
	add_child(player)
	camera = Camera2D.new()
	camera.name = "PlayerCamera"
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.5
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(LEVEL_W)
	camera.limit_bottom = int(H)
	camera.position = Vector2.ZERO
	player.add_child(camera)
	camera.make_current()
	fx_layer = CanvasLayer.new()
	fx_layer.name = "ScreenEffects"
	fx_layer.layer = 2
	add_child(fx_layer)
	vignette = VignetteScript.new()
	fx_layer.add_child(vignette)


func _build_ui() -> void:
	ui = CanvasLayer.new()
	ui.layer = 5
	add_child(ui)
	# Every screen owns its labels. This keeps story, prompt, journal and puzzle
	# text in one coordinate space and lets _update_screen expose only one overlay.
	title_panel = _make_panel("TitlePanel", Vector2(70, 31), Vector2(820, 478), Color(0.028, 0.045, 0.075, 0.96), Color("7198aa"), 20)
	hud_panel = _make_panel("HUDPanel", Vector2(20, 16), Vector2(920, 52), Color(0.022, 0.037, 0.062, 0.94), Color("526d7d"), 12)
	progress_track = _make_panel("ProgressTrack", Vector2(20, 77), Vector2(920, 5), Color("253744"), Color("253744"), 3)
	progress_fill = _make_panel("ProgressFill", Vector2(20, 77), Vector2(92, 5), Color("78d7d2"), Color("78d7d2"), 3)
	era_panel = _make_panel("EraPanel", Vector2(804, 26), Vector2(116, 28), Color("173e47"), Color("75d7c8"), 10)
	story_panel = _make_panel("StoryPanel", Vector2(20, 344), Vector2(650, 114), Color(0.018, 0.032, 0.055, 0.96), Color("506d7d"), 12)
	prompt_panel = _make_panel("PromptPanel", Vector2(20, 474), Vector2(920, 42), Color(0.018, 0.030, 0.052, 0.93), Color("405968"), 10)
	journal_panel = _make_panel("JournalPanel", Vector2(64, 42), Vector2(832, 456), Color(0.022, 0.038, 0.064, 0.985), Color("7893a4"), 18)
	pause_panel = _make_panel("PausePanel", Vector2(246, 170), Vector2(468, 200), Color(0.020, 0.035, 0.060, 0.985), Color("89aabb"), 16)
	puzzle_panel = _make_panel("PuzzlePanel", Vector2(58, 26), Vector2(844, 488), Color(0.020, 0.036, 0.061, 0.99), Color("88c3cf"), 18)
	puzzle_display = PuzzleDisplayScript.new()
	puzzle_display.position = Vector2(48, 120)
	puzzle_display.size = Vector2(748, 224)
	puzzle_panel.add_child(puzzle_display)
	title_label = _make_label(title_panel, "Title", Vector2(48, 36), 52, Color("f7f0de"))
	title_label.size = Vector2(700, 108)
	subtitle_label = _make_label(title_panel, "Subtitle", Vector2(52, 230), 18, Color("c8d9df"))
	subtitle_label.size = Vector2(620, 246)
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hud_label = _make_label(hud_panel, "HUD", Vector2(18, 14), 18, Color("edf3f1"))
	hud_label.size = Vector2(380, 26)
	challenge_label = _make_label(hud_panel, "Challenge", Vector2(420, 17), 12, Color("d6e2e6"))
	challenge_label.size = Vector2(255, 20)
	era_label = _make_label(era_panel, "Era", Vector2(5, 4), 13, Color("f3ebdd"))
	era_label.size = Vector2(106, 20)
	era_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	story_title_label = _make_label(story_panel, "StoryHeading", Vector2(20, 14), 11, Color("f8dda0"))
	story_title_label.size = Vector2(604, 16)
	prompt_label = _make_label(prompt_panel, "Prompt", Vector2(18, 10), 14, Color("b8cbd4"))
	prompt_label.size = Vector2(884, 22)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	story_label = _make_label(story_panel, "Story", Vector2(20, 34), 16, Color("e8edf2"))
	story_label.size = Vector2(604, 62)
	story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay_label = _make_label(pause_panel, "Overlay", Vector2(22, 18), 21, Color("fff1d6"))
	overlay_label.size = Vector2(424, 160)
	overlay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	overlay_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	journal_title_label = _make_label(journal_panel, "JournalTitle", Vector2(32, 26), 23, Color("f8eed8"))
	journal_list_label = _make_label(journal_panel, "JournalList", Vector2(32, 84), 14, Color("cad6df"))
	journal_list_label.size = Vector2(254, 250)
	journal_detail_label = _make_label(journal_panel, "JournalDetail", Vector2(320, 91), 16, Color("e8edf2"))
	journal_detail_label.size = Vector2(466, 252)
	journal_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	journal_hint_label = _make_label(journal_panel, "JournalHint", Vector2(32, 414), 13, Color("a9bdc9"))
	journal_hint_label.size = Vector2(766, 20)
	puzzle_title_label = _make_label(puzzle_panel, "PuzzleTitle", Vector2(48, 28), 23, Color("f7efdf"))
	puzzle_title_label.size = Vector2(748, 28)
	puzzle_body_label = _make_label(puzzle_panel, "PuzzleBody", Vector2(48, 64), 15, Color("cbd9e0"))
	puzzle_body_label.size = Vector2(748, 42)
	puzzle_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	puzzle_hint_label = _make_label(puzzle_panel, "PuzzleHint", Vector2(48, 362), 13, Color("c5d4dc"))
	puzzle_hint_label.size = Vector2(748, 32)
	puzzle_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	puzzle_status_label = _make_label(puzzle_panel, "PuzzleStatus", Vector2(48, 404), 13, Color("f4d889"))
	puzzle_status_label.size = Vector2(748, 18)
	puzzle_controls_label = _make_label(puzzle_panel, "PuzzleControls", Vector2(48, 436), 12, Color("94aebb"))
	puzzle_controls_label.size = Vector2(748, 18)
	for label in [subtitle_label, story_label, journal_detail_label, puzzle_body_label, puzzle_hint_label]:
		label.clip_text = true
	title_panel.visible = true
	for panel in [hud_panel, progress_track, progress_fill, era_panel, story_panel, prompt_panel, journal_panel, pause_panel, puzzle_panel]:
		panel.visible = false
	for label in [hud_label, challenge_label, era_label, story_title_label, story_label, prompt_label, overlay_label, journal_title_label, journal_list_label, journal_detail_label, journal_hint_label, puzzle_title_label, puzzle_body_label, puzzle_hint_label, puzzle_status_label, puzzle_controls_label]:
		label.visible = false


func _make_panel(panel_name: String, at: Vector2, panel_size: Vector2, color: Color, border: Color, radius: int) -> Panel:
	var panel := Panel.new()
	panel.name = panel_name
	panel.position = at
	panel.size = panel_size
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.34)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 3)
	style.anti_aliasing = true
	panel.clip_contents = true
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", style)
	ui.add_child(panel)
	return panel


func _set_panel_tone(panel: Panel, color: Color, border: Color) -> void:
	var style := panel.get_theme_stylebox("panel") as StyleBoxFlat
	if style != null:
		style.bg_color = color
		style.border_color = border


func _make_label(parent: Control, label_name: String, at: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.name = label_name
	label.position = at
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.015, 0.025, 0.04, 0.9))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key: int = (event as InputEventKey).keycode
	if mode == "title":
		if key == KEY_ENTER or key == KEY_KP_ENTER or key == KEY_SPACE:
			_start_game()
		return
	if mode == "ending":
		if key == KEY_ENTER or key == KEY_KP_ENTER or key == KEY_SPACE:
			mode = "title"
			level_index = 0
			repaired.fill(false)
			journal.clear()
			journal_index = 0
			anchor_active = false
			is_past = false
			_refresh_room()
			_update_screen()
		return
	if mode == "paused":
		if key == KEY_ESCAPE or key == KEY_P:
			mode = "playing"
			_update_screen()
		return
	if mode == "puzzle":
		_handle_puzzle_input(key)
		return
	if mode == "journal":
		if key == KEY_J or key == KEY_ESCAPE:
			mode = "playing"
		elif key == KEY_A or key == KEY_LEFT or key == KEY_W or key == KEY_UP:
			journal_index = max(0, journal_index - 1)
		elif key == KEY_D or key == KEY_RIGHT or key == KEY_S or key == KEY_DOWN:
			journal_index = min(LEVELS.size() - 1, journal_index + 1)
		_update_screen()
		return
	if mode != "playing":
		return
	if key == KEY_ESCAPE or key == KEY_P:
		mode = "paused"
		_update_screen()
	elif key == KEY_R:
		_respawn()
	elif key == KEY_E:
		_interact()
	elif key == KEY_Q:
		_shift_time()
	elif key == KEY_J:
		mode = "journal"
		_update_screen()
	elif key == KEY_SPACE:
		_jump()


func _start_game() -> void:
	mode = "playing"
	level_index = 0
	repaired.fill(false)
	journal.clear()
	journal_index = 0
	anchor_active = false
	is_past = false
	_respawn()
	_refresh_room()
	_update_screen()


func _physics_process(delta: float) -> void:
	if mode != "playing":
		return
	room_time += delta
	_update_movers()
	var direction := float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT))
	if direction != 0.0:
		player.velocity.x = move_toward(player.velocity.x, direction * MOVE_SPEED, ACCEL * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, FRICTION * delta)
	var gravity := GRAVITY
	if player.velocity.y < 0.0 and Input.is_key_pressed(KEY_SPACE):
		gravity *= 0.62
	player.velocity.y += gravity * delta
	player.move_and_slide()
	if player.position.y > 590:
		_respawn()
	if player.is_on_floor() and Time.get_ticks_msec() - last_bounce_ms > 420:
		for pad_x in bounce_pads:
			if absf(player.position.x - pad_x) < 30.0:
				player.velocity.y = -760.0
				last_bounce_ms = Time.get_ticks_msec()
				break
	if repaired[level_index] and not is_past and player.position.x > EXIT_X:
		_advance_level()
	queue_redraw()


func _jump() -> void:
	if player.is_on_floor():
		player.velocity.y = -430.0


func _interact() -> void:
	if not anchor_active and absf(player.position.x - ANCHOR_X) < 72.0:
		anchor_active = true
		story_text = "The blue glass is warm. Return here with Q to enter the past, then solve what the memory asks."
		story_time = 5.0
	elif is_past and not repaired[level_index] and absf(player.position.x - MEMORY_X) < 72.0:
		_open_puzzle()
	else:
		story_text = "Find the blue anchor, then inspect the glowing memory in the past."
		story_time = 2.5
	_update_screen()
	queue_redraw()


func _open_puzzle() -> void:
	mode = "puzzle"
	puzzle_cursor = 0
	puzzle_values = _initial_puzzle_values(String(LEVELS[level_index].puzzle))
	puzzle_input.clear()
	puzzle_timer = 0.0
	puzzle_stage = 0
	puzzle_attempts = 0
	puzzle_reveal_time = 3.2 if String(LEVELS[level_index].puzzle) in ["signal", "resonance"] else 0.0
	puzzle_feedback = "Study the mechanism. H reveals a clue if you need it."
	puzzle_hint_visible = false
	player.velocity = Vector2.ZERO
	_update_screen()


func _initial_puzzle_values(puzzle_type: String) -> Array[int]:
	match puzzle_type:
		"moon", "weights", "pipes", "light":
			return [0, 0, 0]
		"clock":
			return [6, 0]
	return []


func _handle_puzzle_input(key: int) -> void:
	if key == KEY_ESCAPE:
		mode = "playing"
		story_text = "The memory waits. Its state will reset when you inspect it again."
		story_time = 2.8
		_update_screen()
		return
	if key == KEY_H:
		puzzle_hint_visible = true
		if String(LEVELS[level_index].puzzle) in ["signal", "resonance"]:
			puzzle_reveal_time = 3.4
		puzzle_feedback = String(LEVELS[level_index].hint)
		_update_screen()
		return
	var action := key == KEY_E or key == KEY_SPACE or key == KEY_ENTER or key == KEY_KP_ENTER
	var previous := key == KEY_A or key == KEY_LEFT
	var next := key == KEY_D or key == KEY_RIGHT
	var increase := key == KEY_W or key == KEY_UP
	var decrease := key == KEY_S or key == KEY_DOWN
	var puzzle_type := String(LEVELS[level_index].puzzle)
	if puzzle_type in ["chime", "echo"]:
		if action:
			_timed_puzzle_press()
		return
	if puzzle_type in ["archive", "signal", "resonance"]:
		if previous:
			puzzle_cursor = posmod(puzzle_cursor - 1, 4)
		elif next:
			puzzle_cursor = posmod(puzzle_cursor + 1, 4)
		elif action:
			_push_puzzle_input()
		_update_screen()
		return
	if previous:
		puzzle_cursor = posmod(puzzle_cursor - 1, puzzle_values.size())
	elif next:
		puzzle_cursor = posmod(puzzle_cursor + 1, puzzle_values.size())
	elif increase:
		_rotate_puzzle_value(1)
	elif decrease:
		_rotate_puzzle_value(-1)
	elif action:
		_submit_value_puzzle()
	_update_screen()


func _rotate_puzzle_value(delta: int) -> void:
	if puzzle_values.is_empty():
		return
	var modulus := 4
	if String(LEVELS[level_index].puzzle) == "clock":
		modulus = 12 if puzzle_cursor == 0 else 60
	puzzle_values[puzzle_cursor] = posmod(puzzle_values[puzzle_cursor] + delta, modulus)
	puzzle_feedback = "The mechanism clicks into a new position."


func _timed_puzzle_press() -> void:
	var puzzle_type := String(LEVELS[level_index].puzzle)
	if puzzle_type == "chime":
		var phase := fposmod(puzzle_timer, 2.8) / 2.8
		if absf(phase - 0.5) <= 0.15:
			_complete_puzzle()
		else:
			_puzzle_failure("Too early or too late. Let the hand enter the gold arc.")
		return
	var phase := fposmod(puzzle_timer, 2.5) / 2.5
	var targets := [0.22, 0.52, 0.82]
	var target: float = targets[puzzle_stage]
	var distance: float = min(absf(phase - target), 1.0 - absf(phase - target))
	if distance <= 0.085:
		puzzle_stage += 1
		puzzle_feedback = "The echo holds. %d of 3 pulses caught." % puzzle_stage
		if puzzle_stage >= targets.size():
			_complete_puzzle()
	else:
		_puzzle_failure("The returning note slips away. Watch the brightest ring.")


func _push_puzzle_input() -> void:
	var puzzle_type := String(LEVELS[level_index].puzzle)
	if puzzle_type in ["signal", "resonance"] and puzzle_reveal_time > 0.0:
		puzzle_feedback = "Watch the ghost pattern before answering."
		return
	if puzzle_type == "archive" and puzzle_input.has(puzzle_cursor):
		puzzle_feedback = "That report is already in the press. Choose another page."
		return
	puzzle_input.append(puzzle_cursor)
	var solution: Array = LEVELS[level_index].solution
	if puzzle_input.size() < solution.size():
		puzzle_feedback = "Memory mark %d of %d recorded." % [puzzle_input.size(), solution.size()]
		return
	if _matches_solution(puzzle_input, solution):
		_complete_puzzle()
	else:
		_puzzle_failure("The order is wrong. The memory folds back to its first mark.")


func _submit_value_puzzle() -> void:
	if _matches_solution(puzzle_values, LEVELS[level_index].solution):
		_complete_puzzle()
	else:
		_puzzle_failure("The mechanism resists. Re-read the markings and try another arrangement.")


func _matches_solution(values: Array, solution: Array) -> bool:
	if values.size() != solution.size():
		return false
	for i in values.size():
		if int(values[i]) != int(solution[i]):
			return false
	return true


func _puzzle_failure(message: String) -> void:
	puzzle_attempts += 1
	puzzle_feedback = message
	puzzle_input.clear()
	puzzle_stage = 0
	puzzle_timer = 0.0
	if puzzle_attempts >= 2:
		puzzle_hint_visible = true


func _complete_puzzle() -> void:
	repaired[level_index] = true
	journal.append("%02d  %s — %s" % [level_index + 1, LEVELS[level_index].place, LEVELS[level_index].clue])
	journal_index = level_index
	mode = "playing"
	story_text = String(LEVELS[level_index].clue)
	story_time = 9.0
	puzzle_feedback = ""
	_refresh_room()
	_update_screen()


func _shift_time() -> void:
	if not anchor_active or absf(player.position.x - ANCHOR_X) > 86.0:
		story_text = "The blue-glass time anchor is near the entrance."
		story_time = 2.6
	else:
		is_past = not is_past
		story_text = "PAST — choose one small thing to set right." if is_past else "PRESENT — the change remembers you."
		story_time = 2.4
		_refresh_room()
	_update_screen()
	queue_redraw()


func _advance_level() -> void:
	if level_index == LEVELS.size() - 1:
		mode = "ending"
		story_text = ""
		_update_screen()
		return
	level_index += 1
	anchor_active = false
	is_past = false
	_respawn()
	_refresh_room()
	story_text = String(LEVELS[level_index - 1].next)
	story_time = 4.0
	_update_screen()


func _respawn() -> void:
	player.position = Vector2(74, 430)
	player.velocity = Vector2.ZERO
	player.reset_physics_interpolation()
	if camera != null:
		camera.reset_smoothing()


func _refresh_room() -> void:
	for child in world.get_children():
		world.remove_child(child)
		child.queue_free()
	movers.clear()
	bounce_pads.clear()
	pulse_shape = null
	room_time = 0.0
	pulse_period = 3.6
	pulse_window = 2.55
	_add_platform(Rect2(0, FLOOR_Y, 640, H - FLOOR_Y))
	_add_platform(Rect2(2260, FLOOR_Y, LEVEL_W - 2260.0, H - FLOOR_Y))
	if _route_is_active():
		_build_route(String(LEVELS[level_index].kind))


func _route_is_active() -> bool:
	return repaired[level_index] and not is_past


func _add_platform(area: Rect2, one_way: bool = false) -> CollisionShape2D:
	var body := StaticBody2D.new()
	body.position = area.position + area.size * 0.5
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = area.size
	collision.shape = shape
	collision.one_way_collision = one_way
	body.add_child(collision)
	world.add_child(body)
	return collision


func _add_mover(size: Vector2, start: Vector2, finish: Vector2, period: float, phase: float = 0.0) -> void:
	var body := AnimatableBody2D.new()
	body.position = start
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	world.add_child(body)
	movers.append({"body":body, "start":start, "finish":finish, "size":size, "period":period, "phase":phase})


func _update_movers() -> void:
	for mover in movers:
		var period: float = float(mover["period"])
		var phase: float = float(mover["phase"])
		var start: Vector2 = mover["start"]
		var finish: Vector2 = mover["finish"]
		var cycle: float = fposmod(room_time / period + phase, 2.0)
		var weight := cycle if cycle <= 1.0 else 2.0 - cycle
		weight = weight * weight * (3.0 - 2.0 * weight)
		var body: AnimatableBody2D = mover["body"]
		var destination: Vector2 = start.lerp(finish, weight)
		body.position = destination
	if pulse_shape != null:
		pulse_shape.disabled = fposmod(room_time, pulse_period) > pulse_window


func _build_route(kind: String) -> void:
	match kind:
		"rope":
			_add_platform(Rect2(640, FLOOR_Y, 1620, 16))
		"clapper":
			_add_platform(Rect2(690, 356, 1515, 18))
			bounce_pads.append(605.0)
		"moons":
			for stone in [Rect2(680, 416, 118, 16), Rect2(900, 355, 100, 16), Rect2(1095, 410, 90, 16), Rect2(1280, 334, 100, 16), Rect2(1480, 400, 94, 16), Rect2(1675, 347, 100, 16), Rect2(1870, 405, 100, 16), Rect2(2070, 350, 125, 16)]:
				_add_platform(stone)
		"lift":
			_add_mover(Vector2(150, 18), Vector2(720, 438), Vector2(2190, 438), 9.6)
		"sluice":
			for stone in [Rect2(685, 428, 92, 16), Rect2(875, 374, 84, 16), Rect2(1050, 426, 90, 16), Rect2(1235, 365, 84, 16), Rect2(1415, 426, 90, 16), Rect2(1600, 374, 84, 16), Rect2(1775, 426, 90, 16), Rect2(1965, 369, 84, 16), Rect2(2140, 426, 90, 16)]:
				_add_platform(stone)
		"light":
			for beam in [Rect2(670, 435, 292, 14), Rect2(1060, 378, 260, 14), Rect2(1420, 435, 270, 14), Rect2(1785, 378, 250, 14), Rect2(2125, 435, 112, 14)]:
				_add_platform(beam, true)
		"gears":
			_add_mover(Vector2(104, 16), Vector2(735, 430), Vector2(920, 334), 2.8)
			_add_mover(Vector2(104, 16), Vector2(1110, 334), Vector2(1295, 430), 2.8, 0.5)
			_add_mover(Vector2(104, 16), Vector2(1485, 430), Vector2(1670, 334), 2.65, 0.25)
			_add_mover(Vector2(104, 16), Vector2(1860, 334), Vector2(2045, 430), 2.65, 0.75)
			_add_platform(Rect2(2140, 435, 96, 16))
		"stairs":
			for shelf in [Rect2(670, 430, 132, 16), Rect2(860, 394, 128, 16), Rect2(1050, 358, 128, 16), Rect2(1240, 394, 128, 16), Rect2(1430, 358, 128, 16), Rect2(1620, 394, 128, 16), Rect2(1810, 358, 128, 16), Rect2(2000, 394, 128, 16), Rect2(2190, 430, 55, 16)]:
				_add_platform(shelf)
		"pulse":
			pulse_period = 7.8
			pulse_window = 5.9
			pulse_shape = _add_platform(Rect2(640, 454, 1620, 16))
		"rings":
			_add_mover(Vector2(78, 16), Vector2(715, 414), Vector2(715, 356), 2.35)
			_add_mover(Vector2(78, 16), Vector2(930, 350), Vector2(930, 414), 2.55, 0.22)
			_add_mover(Vector2(78, 16), Vector2(1145, 414), Vector2(1145, 356), 2.25, 0.44)
			_add_mover(Vector2(78, 16), Vector2(1360, 350), Vector2(1360, 414), 2.45, 0.66)
			_add_mover(Vector2(78, 16), Vector2(1575, 414), Vector2(1575, 356), 2.2, 0.12)
			_add_mover(Vector2(78, 16), Vector2(1790, 350), Vector2(1790, 414), 2.5, 0.38)
			_add_mover(Vector2(78, 16), Vector2(2005, 414), Vector2(2005, 356), 2.3, 0.7)
			_add_mover(Vector2(78, 16), Vector2(2200, 350), Vector2(2200, 414), 2.55, 0.55)
			bounce_pads.append(605.0)


func _update_screen() -> void:
	var active := mode == "playing"
	var title_visible := mode == "title" or mode == "ending"
	var journal_open := mode == "journal"
	var puzzle_open := mode == "puzzle"
	var paused := mode == "paused"
	title_panel.visible = title_visible
	title_label.visible = title_visible
	subtitle_label.visible = title_visible
	hud_panel.visible = active
	progress_track.visible = active
	progress_fill.visible = active
	era_panel.visible = active
	challenge_label.visible = active
	hud_label.visible = active
	era_label.visible = active
	prompt_label.visible = active
	prompt_panel.visible = active
	story_panel.visible = active and story_time > 0.0
	story_title_label.visible = active and story_time > 0.0
	story_label.visible = active and story_time > 0.0
	overlay_label.visible = paused
	journal_panel.visible = journal_open
	pause_panel.visible = paused
	puzzle_panel.visible = puzzle_open
	journal_title_label.visible = journal_open
	journal_list_label.visible = journal_open
	journal_detail_label.visible = journal_open
	journal_hint_label.visible = journal_open
	puzzle_title_label.visible = puzzle_open
	puzzle_body_label.visible = puzzle_open
	puzzle_hint_label.visible = puzzle_open
	puzzle_status_label.visible = puzzle_open
	puzzle_controls_label.visible = puzzle_open
	puzzle_display.visible = puzzle_open
	if vignette != null:
		vignette.set_tint(Color(0.10, 0.06, 0.18, 0.64) if is_past else Color(0.01, 0.025, 0.045, 0.54))
	if mode == "title":
		title_label.text = "ECHOES\nOF ME"
		subtitle_label.text = "A TIME-SHIFTING PLATFORMER\n\nThe house repeats one flood-soaked moment until Mara can hear what survived it.\n\nA / D or ← / →  MOVE     SPACE  JUMP\nE  INTERACT     Q  SHIFT AT ANCHORS\nJ  CASE FILE     R  SAFE ENTRANCE\n\n[ ENTER ]  BEGIN THE RETURN"
	elif paused:
		overlay_label.text = "PAUSED\n\nESC / P  CONTINUE\nR  RETURN TO SAFE ENTRANCE\nJ  READ CASE FILE"
	elif mode == "ending":
		title_label.visible = true
		title_label.text = "THE BELL\nREMEMBERS"
		subtitle_label.visible = true
		subtitle_label.text = "TWO TIMES. ONE MOMENT. 08:17.\n\nMara was found alive downstream after the flood.\nThere was no second girl: the voice was her own,\nreturned by the bell a heartbeat later.\n\nThe routes did not change history. They carried her\nthrough the memory she had buried. Now she can leave.\n\n[ ENTER ]  RETURN TO THE PORCH"
	if journal_open:
		_update_journal_screen()
	if puzzle_open:
		_update_puzzle_screen()
	if active:
		var era := "PAST" if is_past else "PRESENT"
		var level_data: Dictionary = LEVELS[level_index]
		hud_label.text = "%02d / 10    %s" % [level_index + 1, String(level_data.place)]
		era_label.text = era
		_set_panel_tone(era_panel, Color("29223a") if is_past else Color("173e47"), Color("c5adff") if is_past else Color("75d7c8"))
		era_label.add_theme_color_override("font_color", Color("d8c7ff") if is_past else Color("a8f1dc"))
		progress_fill.size.x = 920.0 * float(level_index + 1) / float(LEVELS.size())
		_set_panel_tone(progress_fill, level_data.accent, level_data.accent)
		var tension := "TENSION  "
		for pip in range(7):
			tension += "◆" if pip < int(level_data.tier) else "◇"
		challenge_label.text = tension
		var prompt := "J  CASE FILE     ESC  PAUSE     R  SAFE ENTRANCE"
		if not anchor_active and absf(player.position.x - ANCHOR_X) < 72.0:
			prompt = "E  WAKE THE TIME ANCHOR"
		elif anchor_active and absf(player.position.x - ANCHOR_X) < 86.0:
			prompt = "Q  SHIFT BETWEEN PAST AND PRESENT"
		elif is_past and not repaired[level_index] and absf(player.position.x - MEMORY_X) < 74.0:
			prompt = "E  INSPECT: " + String(level_data.action)
		elif repaired[level_index] and not is_past and player.position.x > EXIT_X - 180.0:
			prompt = "THE NEXT MEMORY IS OPEN  →"
		elif repaired[level_index] and not is_past:
			prompt = String(level_data.mechanic) + "  ·  " + String(level_data.challenge)
		prompt_label.text = prompt
		if repaired[level_index] and story_text == String(level_data.clue):
			story_title_label.text = "MEMORY RECOVERED  ·  %02d / 10     J  CASE FILE" % (level_index + 1)
		elif is_past:
			story_title_label.text = "PAST ECHO  ·  %s" % String(level_data.place)
		else:
			story_title_label.text = "BELLWETHER LOG  ·  %02d / 10" % (level_index + 1)
		story_title_label.add_theme_color_override("font_color", level_data.accent.lightened(0.28))
		story_label.text = story_text
		story_label.visible = story_time > 0.0
	queue_redraw()


func _update_journal_screen() -> void:
	journal_index = clampi(journal_index, 0, LEVELS.size() - 1)
	journal_title_label.text = "CASE FILE  ·  BELLWETHER HOUSE"
	var list_text := ""
	for i in LEVELS.size():
		var prefix := "›" if i == journal_index else " "
		var state := "REC" if i < journal.size() else "---"
		list_text += "%s %02d  %-16s  %s\n" % [prefix, i + 1, String(LEVELS[i].place), state]
	journal_list_label.text = list_text
	if journal_index < journal.size():
		journal_detail_label.text = "RECOVERED FRAGMENT  %02d\n\n%s" % [journal_index + 1, String(LEVELS[journal_index].clue)]
	else:
		journal_detail_label.text = "FRAGMENT %02d  ·  SEALED\n\nRepair this room's past event to restore the missing memory." % (journal_index + 1)
	journal_hint_label.text = "A / D or ← / →  browse memories     J / ESC  close case file"


func _update_puzzle_screen() -> void:
	var level_data: Dictionary = LEVELS[level_index]
	var puzzle_type := String(level_data.puzzle)
	puzzle_title_label.text = "%02d  ·  %s" % [level_index + 1, String(level_data.action).to_upper()]
	puzzle_body_label.text = _puzzle_instruction(puzzle_type)
	puzzle_hint_label.text = "HINT  " + (String(level_data.hint) if puzzle_hint_visible else "Press H when you need a nudge.")
	puzzle_status_label.text = "ATTEMPT %d  ·  %s" % [puzzle_attempts + 1, puzzle_feedback]
	puzzle_controls_label.text = _puzzle_controls(puzzle_type)
	puzzle_display.call("set_puzzle_state", {
		"type":puzzle_type,
		"accent":level_data.accent,
		"values":puzzle_values,
		"cursor":puzzle_cursor,
		"input":puzzle_input,
		"sequence":_display_puzzle_sequence(),
		"timer":puzzle_timer,
		"stage":puzzle_stage,
		"reveal":puzzle_reveal_time > 0.0
	})


func _puzzle_instruction(puzzle_type: String) -> String:
	match puzzle_type:
		"chime": return "Bring the bell back with one clean strike. The moving hand shows its living resonance."
		"echo": return "The clapper is gone; its response returns as three bright pulses. Catch each one."
		"moon": return "Three hooks remember different crescents. Rotate their moons until the mirror reads true."
		"weights": return "The lift only moves when its counterweight has the old three-part balance."
		"pipes": return "Turn the old valves. The cistern must drain before Mara can cross it in the present."
		"light": return "Aim the broken sunlight through each pane and give the sleeping glasshouse a route home."
		"clock": return "The stopped house asks for the precise minute that the report tried to hide."
		"archive": return "Sort the fragments into the order that makes the rescue report whole."
		"signal": return "The lamp relay repeats a six-light memory. Watch the pattern, then answer it."
		"resonance": return "The bell presents its echo. Answer it backwards, then let the final note go."
	return "Recover the missing action."


func _puzzle_controls(puzzle_type: String) -> String:
	if puzzle_type in ["chime", "echo"]:
		return "E / SPACE  STRIKE     H  HINT     ESC  LEAVE MEMORY"
	if puzzle_type in ["archive", "signal", "resonance"]:
		return "A / D  CHOOSE     E / SPACE  PLACE     H  HINT     ESC  LEAVE"
	return "A / D  SELECT     W / S  TURN     E / SPACE  CONFIRM     H  HINT"


func _display_puzzle_sequence() -> Array:
	var result: Array = []
	for item in LEVELS[level_index].solution:
		result.append(int(item))
	if String(LEVELS[level_index].puzzle) == "resonance":
		result.reverse()
	return result


func _process(delta: float) -> void:
	if story_time > 0.0:
		story_time -= delta
		if story_time <= 0.0:
			story_label.visible = false
	if mode == "puzzle":
		puzzle_timer += delta
		if puzzle_reveal_time > 0.0:
			puzzle_reveal_time -= delta
		_update_screen()
	elif mode == "playing":
		_update_screen()


func _draw() -> void:
	var data: Dictionary = LEVELS[level_index]
	var accent: Color = data.accent
	var bg := Color("101a2a") if is_past else Color("202b3d")
	if is_past:
		bg = bg.lerp(accent.darkened(0.65), 0.25)
	draw_rect(Rect2(0, 0, LEVEL_W, H), bg)
	_draw_room_detail(level_index, accent)
	_draw_ambient_particles(accent)
	_draw_lighting(accent)
	# Room beams and window lights create a continuous house-like silhouette.
	for x in range(48, int(LEVEL_W), 145):
		draw_rect(Rect2(x, 95, 2, 350), Color(accent, 0.14))
		draw_rect(Rect2(x + 18, 122 + float((x / 145) % 3) * 20, 38, 3), Color(accent, 0.18))
	# The central void is a readable fall hazard; both sides are safe ground.
	draw_rect(Rect2(0, FLOOR_Y, 640, H - FLOOR_Y), Color("394858") if not is_past else Color("51516a"))
	draw_rect(Rect2(2260, FLOOR_Y, LEVEL_W - 2260.0, H - FLOOR_Y), Color("394858") if not is_past else Color("51516a"))
	draw_rect(Rect2(0, FLOOR_Y, 640, 5), accent)
	draw_rect(Rect2(2260, FLOOR_Y, LEVEL_W - 2260.0, 5), accent)
	_draw_route(data, accent)
	# Time anchor and memory artifact.
	draw_circle(Vector2(ANCHOR_X, 440), 35, Color(accent, 0.08))
	draw_circle(Vector2(ANCHOR_X, 440), 27, Color(accent, 0.12))
	draw_arc(Vector2(ANCHOR_X, 440), 24, room_time * 0.35, room_time * 0.35 + PI * 1.28, 36, Color(accent, 0.85), 2.0)
	draw_arc(Vector2(ANCHOR_X, 440), 18, -room_time * 0.55, -room_time * 0.55 + PI * 0.85, 24, Color("f2e5bc", 0.75), 1.0)
	draw_circle(Vector2(ANCHOR_X, 440), 11, accent if anchor_active else accent.darkened(0.45))
	draw_circle(Vector2(ANCHOR_X, 440), 4, Color("f8f3df"))
	draw_string(ThemeDB.fallback_font, Vector2(ANCHOR_X - 31, 403), "TIME ANCHOR", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, accent)
	_draw_memory_icon(String(data.icon), accent, bg)
	# Door at the far side makes the route's destination explicit.
	draw_rect(Rect2(EXIT_X - 37, 381, 56, 89), Color(accent, 0.12))
	draw_rect(Rect2(EXIT_X - 33, 386, 48, 84), Color(accent, 0.26))
	draw_rect(Rect2(EXIT_X - 26, 393, 34, 77), accent if _route_is_active() else Color("56606b"))
	draw_circle(Vector2(EXIT_X, 434), 3, Color("fff2c5"))
	draw_string(ThemeDB.fallback_font, Vector2(EXIT_X - 48, 375), "NEXT MEMORY", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("e8e0d0"))
	# Mara's simple placeholder silhouette.
	if mode != "title" and mode != "ending":
		var p := player.position
		var body_color := Color("f2e9dd") if not is_past else Color("d7ebf3")
		draw_set_transform(Vector2(p.x, p.y + 17), 0.0, Vector2(1.35, 0.35))
		draw_circle(Vector2.ZERO, 11, Color(0.015, 0.025, 0.04, 0.4))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		draw_circle(Vector2(p.x, p.y - 17), 10, Color("2b2834"))
		draw_circle(Vector2(p.x + 1, p.y - 18), 7, body_color)
		draw_rect(Rect2(p.x - 8, p.y - 10, 16, 22), body_color)
		draw_colored_polygon(PackedVector2Array([Vector2(p.x - 8, p.y - 8), Vector2(p.x + 8, p.y - 3), Vector2(p.x + 8, p.y + 1), Vector2(p.x - 8, p.y - 4)]), Color("d47f70"))
		draw_line(Vector2(p.x - 4, p.y + 10), Vector2(p.x - 8, p.y + 19), body_color, 4)
		draw_line(Vector2(p.x + 4, p.y + 10), Vector2(p.x + 8, p.y + 19), body_color, 4)
		draw_circle(Vector2(p.x + (4 if player.velocity.x >= 0 else -4), p.y - 18), 1.2, Color("20202b"))
		if is_past:
			draw_circle(Vector2(p.x, p.y - 17), 12, Color(accent, 0.22))
	# In-world names, gently different between timelines.
	var chapter_color := Color("c9d7de") if not is_past else Color("d7cbeb")
	draw_string(ThemeDB.fallback_font, Vector2(70, 110), String(data.place), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, chapter_color)
	draw_string(ThemeDB.fallback_font, Vector2(70, 132), "BELLWETHER HOUSE  ·  MEMORY %02d" % (level_index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(chapter_color, 0.68))
	if is_past:
		draw_rect(Rect2(0, 0, LEVEL_W, H), Color("7584c0", 0.055))
	if mode == "title" or mode == "ending":
		for ring in range(4):
			draw_arc(Vector2(755, 270), 85.0 + ring * 24.0, room_time * 0.08 + ring, room_time * 0.08 + ring + 4.4, 48, Color(accent, 0.12 - ring * 0.018), 2.0)


func _draw_route(data: Dictionary, accent: Color) -> void:
	if not _route_is_active():
		return
	var kind: String = data.kind
	var solid := accent.darkened(0.23)
	match kind:
		"rope":
			draw_rect(Rect2(640, FLOOR_Y, 1620, 16), solid)
			for x in range(660, 2260, 42):
				draw_line(Vector2(x, FLOOR_Y), Vector2(x + 14, FLOOR_Y + 14), accent, 2.0)
				draw_line(Vector2(x, FLOOR_Y - 6), Vector2(x, FLOOR_Y), accent, 2.0)
		"clapper":
			draw_line(Vector2(605, 452), Vector2(605, 390), accent, 3.0)
			draw_rect(Rect2(587, 448, 36, 9), Color("ffe19b"))
			draw_arc(Vector2(605, 444), 17, PI, TAU, 20, Color("fff1c7"), 3.0)
			draw_rect(Rect2(690, 356, 1515, 18), solid)
			for x in range(710, 2180, 58):
				draw_line(Vector2(x, 359), Vector2(x + 24, 371), accent, 2.0)
		"moons":
			for stone in [Rect2(680, 416, 118, 16), Rect2(900, 355, 100, 16), Rect2(1095, 410, 90, 16), Rect2(1280, 334, 100, 16), Rect2(1480, 400, 94, 16), Rect2(1675, 347, 100, 16), Rect2(1870, 405, 100, 16), Rect2(2070, 350, 125, 16)]:
				var moon := Vector2(stone.get_center().x, stone.position.y)
				draw_rect(stone, solid)
				draw_circle(moon, 18, Color(accent, 0.28))
				draw_circle(moon, 12, accent)
				draw_circle(moon + Vector2(7, -4), 11, Color("202b3d"))
		"lift":
			_draw_movers(accent)
			if not movers.is_empty():
				var lift: Vector2 = movers[0].body.position
				draw_line(Vector2(lift.x - 60, 190), Vector2(lift.x - 60, lift.y - 8), Color(accent, 0.58), 2.0)
				draw_line(Vector2(lift.x + 60, 190), Vector2(lift.x + 60, lift.y - 8), Color(accent, 0.58), 2.0)
		"sluice":
			draw_rect(Rect2(640, 425, 1620, 45), Color("32859a", 0.45))
			for stone in [Rect2(685, 428, 92, 16), Rect2(875, 374, 84, 16), Rect2(1050, 426, 90, 16), Rect2(1235, 365, 84, 16), Rect2(1415, 426, 90, 16), Rect2(1600, 374, 84, 16), Rect2(1775, 426, 90, 16), Rect2(1965, 369, 84, 16), Rect2(2140, 426, 90, 16)]:
				draw_rect(stone, solid)
				draw_line(stone.position, stone.position + Vector2(stone.size.x, 0), Color("d8ffed"), 2.0)
		"light":
			for beam in [Rect2(670, 435, 292, 14), Rect2(1060, 378, 260, 14), Rect2(1420, 435, 270, 14), Rect2(1785, 378, 250, 14), Rect2(2125, 435, 112, 14)]:
				draw_colored_polygon(PackedVector2Array([Vector2(MEMORY_X, 433), Vector2(beam.position.x, beam.position.y - 10), Vector2(beam.end.x, beam.position.y - 10), Vector2(beam.position.x + 36, 433)]), Color(accent, 0.09))
				draw_rect(beam, Color("f4e5a7"))
				draw_line(beam.position, Vector2(beam.end.x, beam.position.y), Color("fff8cf"), 2.0)
		"gears":
			for gear_center in [Vector2(835, 395), Vector2(1210, 395), Vector2(1585, 395), Vector2(1960, 395)]:
				draw_circle(gear_center, 48, Color(accent, 0.12))
				draw_arc(gear_center, 39, room_time * 0.35, room_time * 0.35 + TAU, 24, accent, 3.0)
			_draw_movers(accent)
		"stairs":
			for shelf in [Rect2(670, 430, 132, 16), Rect2(860, 394, 128, 16), Rect2(1050, 358, 128, 16), Rect2(1240, 394, 128, 16), Rect2(1430, 358, 128, 16), Rect2(1620, 394, 128, 16), Rect2(1810, 358, 128, 16), Rect2(2000, 394, 128, 16), Rect2(2190, 430, 55, 16)]:
				draw_rect(shelf, solid)
				draw_rect(Rect2(shelf.position.x, shelf.position.y - 8, shelf.size.x, 8), Color(accent, 0.72))
				for book_x in range(int(shelf.position.x + 8), int(shelf.end.x - 8), 19):
					draw_rect(Rect2(book_x, shelf.position.y - 24, 14, 16), Color(accent.lightened(0.18), 0.8))
		"pulse":
			var beam_color := Color("fff0a8") if pulse_shape == null or not pulse_shape.disabled else Color(accent, 0.18)
			draw_rect(Rect2(640, 454, 1620, 16), beam_color)
			for x in range(660, 2260, 48):
				draw_line(Vector2(x, 445), Vector2(x + 10, 454), Color(accent, 0.75), 2.0)
		"rings":
			_draw_movers(accent)
			for ring_center in [Vector2(930, 250), Vector2(1360, 250), Vector2(1790, 250), Vector2(2200, 250)]:
				draw_arc(ring_center, 80, room_time * 0.12, room_time * 0.12 + 4.8, 40, Color(accent, 0.18), 2.0)
			draw_rect(Rect2(587, 448, 36, 9), Color("ffe19b"))
			draw_arc(Vector2(605, 444), 17, PI, TAU, 20, Color("fff1c7"), 3.0)


func _draw_room_detail(room: int, accent: Color) -> void:
	# Repeating stone bays tie the ten spaces together; each room layers in its own silhouette.
	for x in range(22, int(LEVEL_W), 156):
		draw_rect(Rect2(x, 118, 3, 292), Color(accent, 0.12))
		draw_rect(Rect2(x - 8, 116, 19, 4), Color(accent, 0.18))
	for x in range(76, int(LEVEL_W), 280):
		draw_rect(Rect2(x, 138 + float((x / 28) % 3) * 12, 92, 3), Color(accent, 0.09))
	match room:
		0:
			for drop in range(22):
				var x := fposmod(float(drop * 83) + room_time * 21.0, LEVEL_W)
				var y := 125.0 + float((drop * 47) % 235)
				draw_line(Vector2(x, y), Vector2(x - 4, y + 13), Color(accent, 0.26), 1.4)
		1:
			for radius in [32.0, 54.0, 76.0]:
				draw_arc(Vector2(510, 248), radius + sin(room_time * 1.5) * 2.0, 0.15, 2.7, 36, Color(accent, 0.13), 2.0)
			for x in [205.0, 770.0]:
				draw_line(Vector2(x, 160), Vector2(x, 305), Color("8b7154", 0.6), 3.0)
				draw_circle(Vector2(x, 310), 10, Color(accent, 0.45))
		2:
			draw_circle(Vector2(790, 173), 35, Color(accent, 0.2))
			draw_circle(Vector2(805, 162), 31, Color("172032", 0.9))
			for star in [Vector2(685, 214), Vector2(858, 235), Vector2(743, 282), Vector2(878, 165)]:
				draw_line(star - Vector2(5, 0), star + Vector2(5, 0), Color("fff2d6", 0.65), 1.0)
				draw_line(star - Vector2(0, 5), star + Vector2(0, 5), Color("fff2d6", 0.65), 1.0)
		3:
			draw_circle(Vector2(772, 188), 42, Color(accent, 0.12))
			draw_arc(Vector2(772, 188), 38, 0, TAU, 32, Color(accent, 0.55), 3.0)
			draw_line(Vector2(772, 150), Vector2(772, 226), Color(accent, 0.35), 2.0)
		4:
			draw_rect(Rect2(310, 432, 340, 38), Color("3a9a9b", 0.15))
			for ripple in range(5):
				var rx := 355.0 + ripple * 66.0 + sin(room_time + ripple) * 8.0
				draw_arc(Vector2(rx, 443), 18.0 + fposmod(room_time * 8.0 + ripple * 9.0, 18.0), PI, TAU, 18, Color("a4f0db", 0.26), 1.5)
		5:
			for ray in range(5):
				var base_x := 500.0 + ray * 77.0
				draw_colored_polygon(PackedVector2Array([Vector2(base_x, 135), Vector2(base_x + 48, 135), Vector2(base_x + 105, 420), Vector2(base_x + 52, 420)]), Color(accent, 0.035))
			for leaf in [Vector2(740, 300), Vector2(830, 330), Vector2(690, 365)]:
				draw_colored_polygon(PackedVector2Array([leaf, leaf + Vector2(22, -11), leaf + Vector2(13, 9)]), Color("9dbd77", 0.6))
		6:
			for gear in [Vector2(758, 211), Vector2(846, 302)]:
				draw_circle(gear, 47, Color(accent, 0.08))
				draw_arc(gear, 39, room_time * 0.25, room_time * 0.25 + TAU, 32, Color(accent, 0.4), 3.0)
				draw_circle(gear, 7, Color(accent, 0.45))
		7:
			for x in [704.0, 782.0, 860.0]:
				draw_rect(Rect2(x, 154, 52, 202), Color("302f42", 0.75))
				for row in range(5):
					draw_rect(Rect2(x + 6, 168 + row * 36, 40, 3), Color(accent, 0.48))
		8:
			draw_circle(Vector2(784, 235), 54, Color(accent, 0.08 + absf(sin(room_time * 2.0)) * 0.08))
			draw_circle(Vector2(784, 235), 18, Color("f4eab5", 0.24 + absf(sin(room_time * 2.0)) * 0.38))
			for root in range(6):
				var root_x := 690.0 + root * 38.0
				draw_line(Vector2(root_x, 390), Vector2(root_x - 18 + root * 4, 470), Color("696080", 0.4), 3.0)
		9:
			draw_arc(Vector2(760, 239), 68, 0.0, TAU, 48, Color(accent, 0.28), 3.0)
			draw_arc(Vector2(760, 239), 92, room_time * 0.12, room_time * 0.12 + TAU, 48, Color(accent, 0.19), 2.0)
			draw_colored_polygon(PackedVector2Array([Vector2(733, 212), Vector2(744, 178), Vector2(776, 178), Vector2(787, 212)]), Color(accent, 0.22))
			draw_line(Vector2(728, 214), Vector2(792, 214), Color(accent, 0.55), 3.0)


func _draw_ambient_particles(accent: Color) -> void:
	# Deterministic drifting dust/rain particles keep the atmosphere active without
	# any external texture or resource dependency.
	var particle_color := Color(accent, 0.24 if is_past else 0.16)
	for particle in range(56):
		var x := fposmod(float(particle * 137) + room_time * (8.0 + float(particle % 5) * 3.0), LEVEL_W)
		var y := 138.0 + fposmod(float(particle * 61) + room_time * (12.0 + float(particle % 4) * 3.0), 270.0)
		var radius := 1.0 + float(particle % 3) * 0.45
		draw_circle(Vector2(x, y), radius, particle_color)


func _draw_lighting(accent: Color) -> void:
	# Layered translucent circles behave as placeholder lights and make time shifts
	# visibly colder than the present without requiring a light texture.
	var anchor_center := Vector2(ANCHOR_X, 418)
	var memory_center := Vector2(MEMORY_X, 418)
	var anchor_tint := Color("b3f4eb") if not is_past else Color("c5afff")
	for ring in range(6, 0, -1):
		var radius := float(ring) * 26.0
		draw_circle(anchor_center, radius, Color(anchor_tint, 0.008 + float(7 - ring) * 0.006))
		draw_circle(memory_center, radius * 0.65, Color(accent, 0.006 + float(7 - ring) * 0.005))
	if _route_is_active() and String(LEVELS[level_index].kind) == "light":
		for x in [780.0, 1180.0, 1560.0, 1910.0]:
			draw_circle(Vector2(x, 350), 82, Color("fff5bf", 0.035))


func _draw_movers(accent: Color) -> void:
	for mover in movers:
		var body: AnimatableBody2D = mover.body
		var size: Vector2 = mover.size
		var rect := Rect2(body.position - size * 0.5, size)
		draw_rect(rect, accent.darkened(0.18))
		draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 4), Color("fff0c7"))
		draw_circle(body.position + Vector2(0, 2), 3.0, accent.lightened(0.25))


func _draw_memory_icon(icon: String, accent: Color, bg: Color) -> void:
	var ink := Color("ffe1a0") if is_past and not repaired[level_index] else accent
	var center := Vector2(MEMORY_X, 438)
	draw_circle(center, 31, Color(accent, 0.07))
	draw_circle(center, 25, Color(accent, 0.16))
	match icon:
		"bell":
			draw_colored_polygon(PackedVector2Array([center + Vector2(-16, 6), center + Vector2(-12, -8), center + Vector2(-6, -17), center + Vector2(6, -17), center + Vector2(12, -8), center + Vector2(16, 6)]), ink)
			draw_line(center + Vector2(-18, 8), center + Vector2(18, 8), ink, 3.0)
			draw_circle(center + Vector2(0, 12), 4, ink)
		"clapper":
			draw_line(center + Vector2(0, -22), center + Vector2(0, 1), ink, 4.0)
			draw_circle(center + Vector2(0, 6), 7, ink)
			draw_arc(center + Vector2(0, -1), 20, 0.1, PI - 0.1, 20, ink, 3.0)
		"moon":
			draw_circle(center, 18, ink)
			draw_circle(center + Vector2(9, -7), 16, bg)
		"weight":
			draw_line(center + Vector2(0, -21), center + Vector2(0, -7), ink, 3.0)
			draw_rect(Rect2(center + Vector2(-12, -6), Vector2(24, 18)), ink)
			draw_rect(Rect2(center + Vector2(-19, 11), Vector2(38, 5)), ink)
		"wheel":
			draw_circle(center, 18, Color(accent, 0.2))
			draw_arc(center, 17, 0, TAU, 20, ink, 3.0)
			draw_circle(center, 5, ink)
			for angle in range(0, 360, 60):
				draw_line(center, center + Vector2.RIGHT.rotated(deg_to_rad(angle)) * 16, ink, 2.0)
		"prism":
			draw_colored_polygon(PackedVector2Array([center + Vector2(-20, 10), center + Vector2(0, -22), center + Vector2(20, 10)]), Color(ink, 0.72))
			draw_line(center + Vector2(0, -22), center + Vector2(0, 10), Color("fff8d4"), 2.0)
		"gear":
			draw_circle(center, 17, ink)
			draw_circle(center, 7, bg)
			for angle in range(0, 360, 45):
				draw_line(center + Vector2.RIGHT.rotated(deg_to_rad(angle)) * 13, center + Vector2.RIGHT.rotated(deg_to_rad(angle)) * 23, ink, 4.0)
		"page":
			draw_colored_polygon(PackedVector2Array([center + Vector2(-14, -22), center + Vector2(11, -18), center + Vector2(12, 16), center + Vector2(-14, 10)]), ink)
			for y in [428, 435, 442]:
				draw_line(Vector2(MEMORY_X - 9, y), Vector2(MEMORY_X + 7, y + 2), bg, 2.0)
		"lamp":
			draw_circle(center + Vector2(0, -7), 11, ink)
			draw_rect(Rect2(center + Vector2(-6, 3), Vector2(12, 9)), ink)
			draw_line(center + Vector2(-6, 15), center + Vector2(6, 15), ink, 3.0)
			for angle in range(0, 360, 45):
				draw_line(center + Vector2(0, -7) + Vector2.RIGHT.rotated(deg_to_rad(angle)) * 16, center + Vector2(0, -7) + Vector2.RIGHT.rotated(deg_to_rad(angle)) * 22, ink, 2.0)
	if is_past and not repaired[level_index]:
		draw_circle(center, 3, Color("fff9dc"))
