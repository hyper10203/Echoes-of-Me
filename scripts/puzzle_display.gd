extends Control
## Primitive puzzle visuals. This UI can be replaced by final art without changing
## the rules held in game.gd.

var puzzle_type := ""
var accent := Color("78d7d2")
var values: Array[int] = []
var cursor := 0
var input: Array[int] = []
var sequence: Array[int] = []
var timer := 0.0
var stage := 0
var reveal_sequence := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_puzzle_state(payload: Dictionary) -> void:
	puzzle_type = String(payload.get("type", ""))
	accent = payload.get("accent", Color("78d7d2"))
	values.clear()
	for value in payload.get("values", []):
		values.append(int(value))
	cursor = int(payload.get("cursor", 0))
	input.clear()
	for value in payload.get("input", []):
		input.append(int(value))
	sequence.clear()
	for value in payload.get("sequence", []):
		sequence.append(int(value))
	timer = float(payload.get("timer", 0.0))
	stage = int(payload.get("stage", 0))
	reveal_sequence = bool(payload.get("reveal", false))
	queue_redraw()


func _draw() -> void:
	_draw_instrument_frame()
	match puzzle_type:
		"chime": _draw_chime()
		"echo": _draw_echo()
		"moon": _draw_moons()
		"weights": _draw_weights()
		"pipes": _draw_pipes()
		"light": _draw_light()
		"clock": _draw_clock()
		"archive": _draw_archive()
		"signal": _draw_signal(false)
		"resonance": _draw_signal(true)


func _draw_instrument_frame() -> void:
	# A reusable, deliberately quiet instrument housing. Puzzle-specific art lives
	# inside this frame, so every mini-game reads as part of the same machine.
	var frame := Rect2(Vector2.ZERO, size)
	var inner := frame.grow(-8.0)
	draw_rect(frame, Color("0b1420"))
	draw_rect(inner, Color("102233"))
	draw_rect(inner.grow(-5.0), Color(accent, 0.035))
	draw_rect(inner, Color(accent, 0.58), false, 1.0)
	draw_line(Vector2(16, 31), Vector2(size.x - 16, 31), Color(accent, 0.32), 1.0)
	for x in range(24, int(size.x) - 24, 42):
		draw_line(Vector2(x, 31), Vector2(x + 8, 31), Color(accent, 0.72), 1.0)
	for dot in range(18):
		var phase := fposmod(timer * 17.0 + float(dot * 29), maxf(1.0, size.x - 52.0))
		var y := 47.0 + fposmod(float(dot * 37), 128.0)
		draw_circle(Vector2(26.0 + phase, y), 1.0, Color(accent, 0.10))
	_text("MEMORY INSTRUMENT", Vector2(18, 21), Color("dbe9e7"), 11)
	_text("LOOP %02d" % (stage + 1), Vector2(size.x - 78, 21), Color(accent, 0.92), 11)
	_draw_corners(inner, Color(accent, 0.95))


func _draw_corners(rect: Rect2, color: Color) -> void:
	var length := 12.0
	draw_line(rect.position, rect.position + Vector2.RIGHT * length, color, 2.0)
	draw_line(rect.position, rect.position + Vector2.DOWN * length, color, 2.0)
	draw_line(Vector2(rect.end.x, rect.position.y), Vector2(rect.end.x - length, rect.position.y), color, 2.0)
	draw_line(Vector2(rect.end.x, rect.position.y), Vector2(rect.end.x, rect.position.y + length), color, 2.0)
	draw_line(Vector2(rect.position.x, rect.end.y), Vector2(rect.position.x + length, rect.end.y), color, 2.0)
	draw_line(Vector2(rect.position.x, rect.end.y), Vector2(rect.position.x, rect.end.y - length), color, 2.0)
	draw_line(rect.end, rect.end - Vector2.RIGHT * length, color, 2.0)
	draw_line(rect.end, rect.end - Vector2.DOWN * length, color, 2.0)


func _draw_chime() -> void:
	var center := Vector2(size.x * 0.5, 90)
	var phase := fposmod(timer, 2.8) / 2.8
	draw_circle(center, 58, Color(accent, 0.08))
	draw_arc(center, 52, 0, TAU, 48, Color(accent, 0.48), 3.0)
	draw_arc(center, 44, PI * 0.72, PI * 1.28, 24, Color("fff0b6"), 8.0)
	draw_line(center, center + Vector2.UP.rotated(TAU * phase) * 44, Color("f7f3e7"), 3.0)
	draw_circle(center, 7, accent)
	_text("STRIKE WHEN THE HAND CROSSES THE GOLDEN ARC", Vector2(170, 182), Color("d6e2e6"), 13)


func _draw_echo() -> void:
	var center := Vector2(size.x * 0.5, 83)
	var phase := fposmod(timer, 2.5) / 2.5
	for ring in range(4):
		draw_arc(center, 16.0 + ring * 18.0 + phase * 14.0, 0, TAU, 48, Color(accent, 0.50 - ring * 0.08), 2.0)
	for i in 3:
		var dot := Vector2(200 + i * 180, 188)
		var caught := i < stage
		draw_circle(dot, 13, accent if caught else Color("293848"))
		draw_circle(dot, 5, Color("f9f0ca") if caught else Color("687584"))
	_text("CATCH %d OF 3 RETURNING PULSES" % (stage + 1), Vector2(230, 208), Color("d6e2e6"), 13)


func _draw_moons() -> void:
	for i in 3:
		var center := Vector2(185 + i * 205, 97)
		var selected := i == cursor
		draw_circle(center, 50, Color(accent, 0.13 if selected else 0.045))
		draw_arc(center, 46, 0, TAU, 32, accent if selected else Color("44505b"), 3.0 if selected else 1.0)
		var turn := values[i] if i < values.size() else 0
		var moon_center := center + Vector2.RIGHT.rotated(TAU * float(turn) / 4.0) * 5.0
		draw_circle(moon_center, 23, Color("f7dfae"))
		draw_circle(moon_center + Vector2.RIGHT.rotated(TAU * float(turn) / 4.0) * 11.0, 21, Color("172032"))
		_text("HOOK %d" % (i + 1), center + Vector2(-26, 72), Color("c5d4dc"), 11)
	for i in 3:
		var target_center := Vector2(305 + i * 56, 195)
		var target_turn := sequence[i] if i < sequence.size() else 0
		draw_circle(target_center, 11, Color("f7dfae", 0.75))
		draw_circle(target_center + Vector2.RIGHT.rotated(TAU * float(target_turn) / 4.0) * 5.0, 10, Color("172032"))
	_text("MIRROR", Vector2(172, 198), Color("e5b6ce"), 11)
	_text("MATCH THE CRESCENTS TO THEIR REFLECTION", Vector2(172, 208), Color("d6e2e6"), 13)


func _draw_weights() -> void:
	var base := Vector2(size.x * 0.5, 185)
	draw_line(base + Vector2(-180, 0), base + Vector2(180, 0), Color("bfc8cb"), 4.0)
	draw_line(base, base + Vector2(0, 28), Color("bfc8cb"), 4.0)
	draw_colored_polygon(PackedVector2Array([base + Vector2(-30, 30), base + Vector2(30, 30), base]), Color(accent, 0.48))
	for i in 3:
		var value := values[i] if i < values.size() else 0
		var x := 225.0 + i * 150.0
		var selected := i == cursor
		draw_rect(Rect2(x - 42, 45, 84, 103), Color(accent, 0.12 if selected else 0.04))
		draw_rect(Rect2(x - 40, 47, 80, 99), accent if selected else Color("455261"), false, 2.0)
		for block in range(value):
			draw_rect(Rect2(x - 22, 132 - block * 21, 44, 16), Color("f2c77d"))
		_text("%d" % value, Vector2(x - 4, 82), Color("f5f0e4"), 22)
	_text("BALANCE: LIGHT + MIDDLE + HEAVY", Vector2(220, 208), Color("d6e2e6"), 13)


func _draw_pipes() -> void:
	for i in 3:
		var center := Vector2(185 + i * 205, 108)
		var selected := i == cursor
		draw_rect(Rect2(center - Vector2(56, 56), Vector2(112, 112)), Color(accent, 0.08 if selected else 0.035))
		draw_rect(Rect2(center - Vector2(54, 54), Vector2(108, 108)), accent if selected else Color("566371"), false, 3.0)
		var angle := TAU * float(values[i] if i < values.size() else 0) / 4.0
		draw_line(center + Vector2.LEFT.rotated(angle) * 43, center, Color("82e6d0"), 12.0)
		draw_line(center, center + Vector2.RIGHT.rotated(angle) * 43, Color("82e6d0"), 12.0)
		draw_circle(center, 15, Color("d7fbec"))
		_text("%d" % (i + 1), center + Vector2(-4, 5), Color("1c4d50"), 12)
	_text("TURN THREE VALVES UNTIL THE WATER REACHES THE DRAIN", Vector2(126, 208), Color("d6e2e6"), 13)


func _draw_light() -> void:
	var source := Vector2(88, 166)
	var target := Vector2(size.x - 84, 54)
	draw_circle(source, 17, Color("fff1aa"))
	draw_circle(target, 23, Color(accent, 0.16))
	draw_circle(target, 10, Color("f8ffd2"))
	var previous := source
	for i in 3:
		var point := Vector2(235 + i * 145, 124 - (i % 2) * 50)
		var selected := i == cursor
		draw_line(previous, point, Color("fff5be", 0.24), 3.0)
		draw_rect(Rect2(point - Vector2(23, 23), Vector2(46, 46)), accent if selected else Color("6c7b70"), false, 2.0)
		var mirror_angle := TAU * float(values[i] if i < values.size() else 0) / 4.0 + PI * 0.25
		draw_line(point - Vector2.RIGHT.rotated(mirror_angle) * 20, point + Vector2.RIGHT.rotated(mirror_angle) * 20, Color("f4e2a1"), 5.0)
		previous = point
	draw_line(previous, target, Color("fff5be", 0.24), 3.0)
	_text("ROTATE THE GLASS TO LEAD LIGHT HOME", Vector2(210, 208), Color("d6e2e6"), 13)


func _draw_clock() -> void:
	for i in 2:
		var center := Vector2(255 + i * 250, 105)
		var selected := i == cursor
		var value := values[i] if i < values.size() else 0
		draw_circle(center, 62, Color(accent, 0.07 if selected else 0.035))
		draw_arc(center, 56, 0, TAU, 48, accent if selected else Color("687582"), 3.0)
		for notch in range(12):
			var direction := Vector2.UP.rotated(TAU * float(notch) / 12.0)
			draw_line(center + direction * 44, center + direction * 51, Color("dfe4da"), 2.0)
		var divisor := 12.0 if i == 0 else 60.0
		draw_line(center, center + Vector2.UP.rotated(TAU * float(value) / divisor) * 40, Color("f4d889"), 4.0)
		draw_circle(center, 5, accent)
		_text("HOUR" if i == 0 else "MINUTE", center + Vector2(-24, 80), Color("c5d4dc"), 11)
	_text("SET THE HOUSE CLOCK TO 08:17", Vector2(230, 208), Color("d6e2e6"), 13)


func _draw_archive() -> void:
	var names := ["REPORT", "RESCUE", "ALARM", "SEARCH"]
	for i in 4:
		var point := Vector2(120 + i * 150, 105)
		var selected := i == cursor
		var placed := input.find(i) >= 0
		draw_rect(Rect2(point - Vector2(55, 43), Vector2(110, 86)), Color(accent, 0.13 if selected else 0.045))
		draw_rect(Rect2(point - Vector2(53, 41), Vector2(106, 82)), accent if selected else Color("64707c"), false, 2.0)
		_text(names[i], point + Vector2(-34, -3), Color("f4efdd") if placed else Color("c5d4dc"), 11)
		if placed:
			_text("%d" % (input.find(i) + 1), point + Vector2(-4, 25), accent, 17)
	_text("PLACE THE REPORTS IN THE ORDER THEY HAPPENED", Vector2(162, 208), Color("d6e2e6"), 13)


func _draw_signal(finale: bool) -> void:
	var labels := ["PAST", "ECHO", "SELF", "BELL"] if finale else ["NORTH", "EAST", "SOUTH", "WEST"]
	for i in 4:
		var point := Vector2(145 + i * 170, 104)
		var selected := i == cursor
		var selected_count := input.count(i)
		var reveal := reveal_sequence and sequence.find(i) >= 0
		draw_circle(point, 42, Color(accent, 0.18 if selected else 0.055))
		draw_arc(point, 39, 0, TAU, 32, accent if selected else Color("52606d"), 3.0)
		draw_circle(point, 21, Color("f4e7a5") if reveal or selected_count > 0 else Color("344250"))
		_text(labels[i], point + Vector2(-22, 4), Color("17202b") if reveal or selected_count > 0 else Color("d5dee3"), 10)
		if selected_count > 0:
			_text("%d" % (input.find(i) + 1), point + Vector2(-4, 65), accent, 15)
	var instruction := "REPEAT THE SIGNAL" if not finale else "ANSWER THE ECHO IN REVERSE"
	if reveal_sequence:
		for step in sequence.size():
			var marker := Vector2(126 + step * 82, 202)
			draw_circle(marker, 14, accent)
			_text("%d" % (step + 1), marker + Vector2(-4, 5), Color("17202b"), 12)
			_text(labels[sequence[step]].substr(0, 1), marker + Vector2(-4, -27), Color("f4e7a5"), 12)
	_text(instruction + "  %d / %d" % [input.size(), sequence.size()], Vector2(220, 208), Color("d6e2e6"), 13)


func _text(text: String, at: Vector2, color: Color, font_size: int) -> void:
	draw_string(ThemeDB.fallback_font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
