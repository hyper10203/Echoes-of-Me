extends SceneTree
## Headless game-flow check. Run with:
## Godot --headless --path . --script res://tests/smoke.gd

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	_check(game.get("mode") == "title", "fresh launch opens title")
	_check(game.get("camera") != null and game.get("camera").get_parent() == game.get("player"), "camera is attached to Mara")
	_check(game.get("camera").limit_right == 2880, "camera has the large room boundary")
	game.call("_start_game")
	_check(game.get("mode") == "playing", "start enters gameplay")
	_check_ui_layout(game)
	game.call("_input", _key(KEY_P))
	_check(game.get("mode") == "paused", "pause key pauses")
	game.call("_input", _key(KEY_ESCAPE))
	_check(game.get("mode") == "playing", "escape resumes")
	var player: CharacterBody2D = game.get("player")
	for _frame in 35:
		await physics_frame
	var start_x := player.position.x
	Input.parse_input_event(_key(KEY_D))
	for _frame in 8:
		await physics_frame
	var release_d := _key(KEY_D)
	release_d.pressed = false
	Input.parse_input_event(release_d)
	_check(player.position.x > start_x + 10.0, "keyboard movement moves Mara")
	var start_y := player.position.y
	Input.parse_input_event(_key(KEY_SPACE))
	for _frame in 2:
		await physics_frame
	_check(player.position.y < start_y, "space jumps from the floor")
	var release_space := _key(KEY_SPACE)
	release_space.pressed = false
	Input.parse_input_event(release_space)
	var kinds: Array[String] = []
	var puzzles: Array[String] = []
	var tiers: Array[int] = []
	for level in 10:
		_check(game.get("level_index") == level, "level %d is reached" % (level + 1))
		var data: Dictionary = game.get("LEVELS")[level]
		kinds.append(String(data.kind))
		puzzles.append(String(data.puzzle))
		tiers.append(int(data.tier))
		player.position = Vector2(260, 430)
		game.call("_interact")
		_check(game.get("anchor_active"), "level %d anchor activates" % (level + 1))
		game.call("_shift_time")
		_check(game.get("is_past"), "level %d enters the past" % (level + 1))
		player.position = Vector2(515, 430)
		game.call("_interact")
		_check(game.get("mode") == "puzzle", "level %d opens its memory puzzle" % (level + 1))
		_check(not game.get("story_panel").visible and not game.get("prompt_panel").visible and not game.get("hud_panel").visible, "puzzle screen exclusively hides gameplay UI in level %d" % (level + 1))
		_check(String(data.puzzle) == _active_puzzle_type(game), "level %d exposes its intended puzzle type" % (level + 1))
		if level == 2:
			game.set("puzzle_values", [0, 0, 0])
			game.call("_submit_value_puzzle")
			_check(game.get("mode") == "puzzle" and game.get("puzzle_attempts") == 1, "wrong puzzle solution stays local and offers recovery")
		if level == 8:
			game.call("_input", _key(KEY_H))
			_check(game.get("puzzle_hint_visible"), "H reveals a fair late-puzzle hint")
		_solve_current_puzzle(game, data)
		var repaired: Array = game.get("repaired")
		_check(repaired[level], "level %d repair persists after solving its puzzle" % (level + 1))
		_check(game.get("journal").size() == level + 1, "level %d clue enters the case file" % (level + 1))
		if level == 0:
			game.call("_input", _key(KEY_J))
			_check(game.get("mode") == "journal", "J opens the case file")
			_check(not game.get("story_panel").visible and not game.get("prompt_panel").visible and not game.get("hud_panel").visible, "case file exclusively hides gameplay UI")
			_check(game.get("journal_detail_label").text.contains("bell rings twice"), "case file retains the recovered clue")
			game.call("_input", _key(KEY_J))
		_check(not game.call("_route_is_active"), "past route stays unavailable in level %d" % (level + 1))
		player.position = Vector2(260, 430)
		game.call("_shift_time")
		_check(not game.get("is_past"), "level %d returns to the present" % (level + 1))
		_check(game.call("_route_is_active"), "level %d route appears after the repair" % (level + 1))
		_check(game.get("world").get_child_count() > 2, "level %d builds a route in its larger room" % (level + 1))
		if level == 3:
			_check(game.get("movers").size() == 1, "laundry level has a moving lift")
			_check(await _mover_moves(game, 0), "laundry lift travels")
		if level == 6:
			_check(game.get("movers").size() == 4, "clock room creates four timed gear platforms")
			_check(await _mover_moves(game, 0), "clock gear platforms move")
		if level == 8:
			_check(game.get("pulse_shape") != null, "undercroft creates a pulsing bridge")
			game.set("room_time", 6.2)
			game.call("_update_movers")
			_check(game.get("pulse_shape").disabled, "signal bridge fades on its off beat")
			game.set("room_time", 1.0)
			game.call("_update_movers")
			_check(not game.get("pulse_shape").disabled, "signal bridge returns on its bright beat")
		if level == 9:
			_check(game.get("movers").size() == 8, "tower creates eight moving bell rings")
			_check(await _mover_moves(game, 0), "tower rings oscillate")
		if level == 0:
			player.position = Vector2(1300, 300)
			game.call("_respawn")
			_check(player.position == Vector2(74, 430), "restart returns to the safe entrance")
			_check(repaired[0], "restart preserves a completed repair")
		if level < 9:
			game.call("_advance_level")
	_check(kinds.size() == kinds.duplicate().size(), "all ten traversal routes are distinct")
	_check(puzzles.size() == puzzles.duplicate().size(), "all ten memory puzzles are distinct")
	_check(tiers[0] < tiers[1] and tiers[1] < tiers[2] and tiers[2] <= tiers[3] and tiers[3] < tiers[4] and tiers[4] <= tiers[5] and tiers[5] < tiers[6] and tiers[6] <= tiers[7] and tiers[7] < tiers[8] and tiers[8] < tiers[9], "puzzle complexity rises steadily to the finale")
	_check(game.get("level_index") == 9, "all ten levels are playable")
	game.call("_advance_level")
	_check(game.get("mode") == "ending", "final doorway reaches the ending")
	if failures.is_empty():
		print("PASS: player camera, ten unique puzzles, ten routes, case file, timing, checkpoints, progression, and ending")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _active_puzzle_type(game: Node) -> String:
	return String(game.get("LEVELS")[game.get("level_index")].puzzle)


func _check_ui_layout(game: Node) -> void:
	var story := _screen_rect(game.get("story_panel"))
	var prompt := _screen_rect(game.get("prompt_panel"))
	_check(not story.intersects(prompt), "story card and interaction prompt have separate screen space")
	var title := _screen_rect(game.get("title_label"))
	var subtitle := _screen_rect(game.get("subtitle_label"))
	_check(not title.intersects(subtitle), "title and instructions have separate screen space")
	var puzzle_body := _screen_rect(game.get("puzzle_body_label"))
	var puzzle_display := _screen_rect(game.get("puzzle_display"))
	var puzzle_hint := _screen_rect(game.get("puzzle_hint_label"))
	_check(not puzzle_body.intersects(puzzle_display) and not puzzle_display.intersects(puzzle_hint), "puzzle copy, instrument, and hint do not overlap")
	var journal_list := _screen_rect(game.get("journal_list_label"))
	var journal_detail := _screen_rect(game.get("journal_detail_label"))
	_check(not journal_list.intersects(journal_detail), "case-file index and evidence detail do not overlap")


func _screen_rect(control: Control) -> Rect2:
	var position := control.position
	var parent := control.get_parent()
	while parent != null:
		if parent is Control:
			position += (parent as Control).position
		parent = parent.get_parent()
	return Rect2(position, control.size)


func _solve_current_puzzle(game: Node, data: Dictionary) -> void:
	var puzzle_type := String(data.puzzle)
	if puzzle_type == "chime":
		game.set("puzzle_timer", 1.4)
		game.call("_timed_puzzle_press")
		return
	if puzzle_type == "echo":
		for time_mark in [0.55, 1.30, 2.05]:
			game.set("puzzle_timer", time_mark)
			game.call("_timed_puzzle_press")
		return
	if puzzle_type == "moon":
		game.call("_input", _key(KEY_W))
		game.call("_input", _key(KEY_RIGHT))
		game.call("_input", _key(KEY_S))
		game.call("_input", _key(KEY_RIGHT))
		game.call("_input", _key(KEY_W))
		game.call("_input", _key(KEY_W))
		game.call("_input", _key(KEY_E))
		return
	if puzzle_type in ["archive", "signal", "resonance"]:
		game.set("puzzle_reveal_time", 0.0)
		for symbol in data.solution:
			game.set("puzzle_cursor", int(symbol))
			game.call("_push_puzzle_input")
		return
	var values: Array[int] = []
	for value in data.solution:
		values.append(int(value))
	game.set("puzzle_values", values)
	game.call("_submit_value_puzzle")


func _mover_moves(game: Node, index: int) -> bool:
	var body: AnimatableBody2D = game.get("movers")[index].body
	var start: Vector2 = body.position
	for _frame in 24:
		await physics_frame
	return body.position.distance_to(start) > 1.0


func _key(code: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	return event


func _check(condition: bool, description: String) -> void:
	if not condition:
		failures.append(description)
