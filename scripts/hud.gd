class_name RiftHUD
extends CanvasLayer

var arena: Node3D
var root: Control
var overlay: CenterContainer
var title: Label
var description: Label
var choice_label: Label
var hero_preview: RiftHeroPreview
var hero_details: HBoxContainer
var combat_panel: PanelContainer
var choice_row: HBoxContainer
var launch: Button
var moving_targets_option: CheckButton
var selection_button: Button
var practice_button: Button
var resume_button: Button
var top: Label
var info: Label
var hp_label: Label
var hp_bar: ProgressBar
var skill_labels: Array[Label] = []
var skill_bars: Array[ProgressBar] = []
var skill_styles: Array[StyleBoxFlat] = []
var passive_label: Label
var minimap: RiftMinimap
var reticle: Control
var countdown_label: Label
var toast_message := ""
var notification_time := 0.0
var paused_menu := false
var hit_time := 0.0
var was_blocked := false
var preferences_timer: Timer
var preferences_dirty := false

func label(words: String,font: int = 18,color: Color = Color("e5eadf")) -> Label:
	var node := Label.new()
	node.text = words
	node.add_theme_font_size_override("font_size",font)
	node.modulate = color
	return node

func style() -> StyleBoxFlat:
	var value := StyleBoxFlat.new()
	value.bg_color = Color(.025,.05,.06,.96)
	value.border_color = Color("496259")
	value.set_border_width_all(1)
	value.set_corner_radius_all(8)
	value.content_margin_left = 18
	value.content_margin_right = 18
	value.content_margin_top = 12
	value.content_margin_bottom = 12
	return value

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	preferences_timer = Timer.new()
	preferences_timer.one_shot = true
	preferences_timer.wait_time = .35
	add_child(preferences_timer)
	preferences_timer.timeout.connect(flush_preferences)
	root = Control.new()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var margin := MarginContainer.new()
	root.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left","right","top","bottom"]:
		margin.add_theme_constant_override("margin_"+edge,24)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var layout := VBoxContainer.new()
	layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(layout)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel",style())
	layout.add_child(panel)
	top = label("R I F T   /   ARENA 3 × 3",21)
	panel.add_child(top)
	var middle := Control.new()
	middle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(middle)
	info = label("",17,Color("efcd99"))
	middle.add_child(info)
	info.position = Vector2(0,14)
	minimap = RiftMinimap.new()
	minimap.arena = arena
	middle.add_child(minimap)
	minimap.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	minimap.offset_left = -225
	minimap.offset_right = 0
	minimap.offset_top = 14
	minimap.offset_bottom = 209
	minimap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var map_name := label("MAPA · ZONA SEGURA",12)
	map_name.position = Vector2(10,3)
	minimap.add_child(map_name)
	var bottom := PanelContainer.new()
	combat_panel = bottom
	bottom.add_theme_stylebox_override("panel",style())
	layout.add_child(bottom)
	var rows := VBoxContainer.new()
	bottom.add_child(rows)
	var health_row := HBoxContainer.new()
	rows.add_child(health_row)
	hp_label = label("",19)
	hp_label.custom_minimum_size.x = 270
	health_row.add_child(hp_label)
	hp_bar = ProgressBar.new()
	hp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hp_bar.show_percentage = false
	hp_bar.custom_minimum_size.y = 16
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("63cdb4")
	fill.set_corner_radius_all(4)
	hp_bar.add_theme_stylebox_override("fill",fill)
	health_row.add_child(hp_bar)
	passive_label = label("SEM BÔNUS",15,Color("bce0cc"))
	passive_label.custom_minimum_size.x = 240
	passive_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	health_row.add_child(passive_label)
	var skills := HBoxContainer.new()
	skills.add_theme_constant_override("separation",24)
	rows.add_child(skills)
	for i in 5:
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var card_style := StyleBoxFlat.new()
		card_style.bg_color = Color(.055,.085,.09,.92)
		card_style.border_color = Color("375b55")
		card_style.set_border_width_all(1)
		card_style.set_corner_radius_all(4)
		card_style.content_margin_left = 9
		card_style.content_margin_right = 9
		card_style.content_margin_top = 6
		card_style.content_margin_bottom = 6
		card.add_theme_stylebox_override("panel",card_style)
		skill_styles.append(card_style)
		skills.add_child(card)
		var content := VBoxContainer.new()
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(content)
		var text := label("",15)
		content.add_child(text)
		skill_labels.append(text)
		var recharge := ProgressBar.new()
		recharge.min_value = 0
		recharge.max_value = 1
		recharge.show_percentage = false
		recharge.custom_minimum_size.y = 4
		recharge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var charge_style := StyleBoxFlat.new()
		charge_style.bg_color = Color("64b9aa")
		recharge.add_theme_stylebox_override("fill",charge_style)
		content.add_child(recharge)
		skill_bars.append(recharge)
	rows.add_child(label("WASD mover   ·   Mouse: mira livre   ·   Q/E/R/F: usar   ·   Shift + habilidade: prévia   ·   Direito cancela   ·   Esc pausa",13,Color("aec0b5")))
	reticle = Control.new()
	root.add_child(reticle)
	reticle.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	reticle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reticle.draw.connect(draw_reticle)
	countdown_label = label("",50)
	root.add_child(countdown_label)
	countdown_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	countdown_label.offset_left = -320
	countdown_label.offset_right = 320
	countdown_label.offset_top = -100
	countdown_label.offset_bottom = -30
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	build_menu()
	show_selection()

func build_menu() -> void:
	overlay = CenterContainer.new()
	root.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 730
	panel.add_theme_stylebox_override("panel",style())
	overlay.add_child(panel)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation",10)
	panel.add_child(list)
	list.add_child(label("R I F T   /   TERCEIRA PESSOA",16,Color("8bcbb4")))
	title = label("Escolha seu personagem",32)
	list.add_child(title)
	description = label("Um jogador + cinco bots. Elimine os três rivais.\nSem renascimento. Dispute runas e evite a zona de perigo.",17)
	list.add_child(description)
	choice_row = HBoxContainer.new()
	list.add_child(choice_row)
	for hero in ["warrior","mage"]:
		var button := Button.new()
		button.text = RiftRules.HEROES[hero].name
		button.custom_minimum_size.y = 45
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func():
			arena.selected_hero = hero
			update_choice())
		choice_row.add_child(button)
	hero_details = HBoxContainer.new()
	hero_details.add_theme_constant_override("separation",15)
	list.add_child(hero_details)
	hero_preview = RiftHeroPreview.new()
	hero_details.add_child(hero_preview)
	choice_label = label("",16,Color("c5d7c7"))
	choice_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hero_details.add_child(choice_label)
	list.add_child(label("Resposta da câmera",13))
	var sensitivity := HSlider.new()
	sensitivity.min_value = 4
	sensitivity.max_value = 16
	sensitivity.step = .1
	sensitivity.value = arena.settings.camera_follow_speed
	sensitivity.value_changed.connect(func(value: float): arena.settings.camera_follow_speed = value)
	sensitivity.value_changed.connect(func(_value: float):
		preferences_dirty = true
		preferences_timer.start())
	list.add_child(sensitivity)
	list.add_child(label("Distância da câmera",13))
	var distance := HSlider.new()
	distance.min_value = 3.5
	distance.max_value = 8
	distance.step = .1
	distance.value = arena.settings.camera_distance
	distance.value_changed.connect(func(value: float): arena.settings.camera_distance = value)
	distance.value_changed.connect(func(_value: float):
		preferences_dirty = true
		preferences_timer.start())
	list.add_child(distance)
	list.add_child(label("Volume dos efeitos",13))
	var volume := HSlider.new()
	volume.min_value = 0
	volume.max_value = 1
	volume.step = .05
	volume.value = arena.settings.effects_volume
	volume.value_changed.connect(func(value: float): arena.settings.effects_volume = value)
	volume.value_changed.connect(func(_value: float):
		preferences_dirty = true
		preferences_timer.start())
	list.add_child(volume)
	launch = Button.new()
	launch.text = "ENTRAR NA ARENA"
	launch.custom_minimum_size.y = 48
	launch.pressed.connect(func(): arena.start_round(arena.selected_hero))
	list.add_child(launch)
	practice_button = Button.new()
	practice_button.text = "TREINO LIVRE"
	practice_button.custom_minimum_size.y = 38
	practice_button.pressed.connect(func(): arena.start_round(arena.selected_hero,true,true))
	list.add_child(practice_button)
	moving_targets_option = CheckButton.new()
	moving_targets_option.text = "Alvos em movimento no treino"
	moving_targets_option.toggled.connect(func(value: bool): arena.moving_targets = value)
	list.add_child(moving_targets_option)
	resume_button = Button.new()
	resume_button.text = "CONTINUAR"
	resume_button.custom_minimum_size.y = 42
	resume_button.pressed.connect(resume_game)
	list.add_child(resume_button)
	selection_button = Button.new()
	selection_button.text = "TROCAR PERSONAGEM / MODO"
	selection_button.pressed.connect(func():
		arena.clear_round()
		arena.overview.current = true
		show_selection())
	list.add_child(selection_button)
	list.add_child(label("Clique: um ataque   ·   Espaço: mobilidade   ·   Q/E/R/F: ao pressionar\nShift + habilidade: prévia sem usar   ·   Tab: trocar aliado ao observar",13,Color("a9bfb0")))

func update_choice() -> void:
	hero_preview.show_hero(arena.selected_hero)
	if arena.selected_hero == "warrior":
		choice_label.text = "GUERREIRO  ·  270 de vida  ·  Combate próximo\nQ Investida    E Guarda frontal    R Golpe sísmico\nAproxime-se, proteja-se e puna inimigos próximos."
	else:
		choice_label.text = "MAGO  ·  200 de vida  ·  Distância e controle\nQ Orbe explosivo    E Passo arcano    R Campo glacial\nMantenha distância e controle áreas com magia."

func show_selection() -> void:
	title.text = "Escolha seu personagem"
	description.text = "Arena 3×3 com bots ou treino livre com alvos.\nWASD move · mouse mira · Espaço usa mobilidade."
	choice_row.show()
	choice_label.show()
	hero_details.show()
	launch.show()
	launch.text = "ENTRAR NA ARENA"
	practice_button.show()
	moving_targets_option.show()
	selection_button.hide()
	overlay.show()
	resume_button.hide()
	update_choice()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_menu() -> void:
	overlay.hide()
	paused_menu = false
	get_tree().paused = false
	notification_time = 0

func pause_game() -> void:
	if not arena.active and arena.countdown < 0:
		return
	for action in ["move_left","move_right","move_forward","move_back"]:
		Input.action_release(action)
	get_tree().paused = true
	paused_menu = true
	if is_instance_valid(arena.player):
		arena.player.cancel_prepare()
	title.text = "PAUSA"
	description.text = "Combate e temporizadores congelados."
	choice_row.hide()
	choice_label.hide()
	hero_details.hide()
	launch.hide()
	practice_button.hide()
	moving_targets_option.visible = arena.practice_mode
	selection_button.show()
	resume_button.show()
	overlay.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func resume_game() -> void:
	close_menu()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func show_result(reason: String) -> void:
	title.text = arena.result
	description.text = "Rodada %d · %02d:%02d\nAZUL %d  :  %d CORAL\n%s" % [arena.round_number,int(arena.elapsed/60),int(arena.elapsed)%60,arena.score[0],arena.score[1],reason]
	if is_instance_valid(arena.player):
		description.text += "\nVocê: %d eliminações · %.0f de dano · %d runas" % [arena.player.eliminations,arena.player.damage_dealt,arena.player.runes_collected]
	choice_row.show()
	choice_label.show()
	hero_details.show()
	launch.show()
	launch.text = "PRÓXIMA RODADA"
	practice_button.show()
	moving_targets_option.show()
	selection_button.hide()
	resume_button.hide()
	update_choice()
	overlay.show()

func hit_confirm(blocked: bool) -> void:
	hit_time = .18
	was_blocked = blocked

func notify(message: String,duration: float = 1.5) -> void:
	toast_message = message
	notification_time = duration

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_ESCAPE:
			if paused_menu:
				resume_game()
			else:
				pause_game()
			get_viewport().set_input_as_handled()
		elif event.physical_keycode == KEY_TAB and is_instance_valid(arena.player) and not arena.player.alive:
			arena.cycle_spectator()
			get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(overlay):
		pause_game()

func _process(dt: float) -> void:
	minimap.queue_redraw()
	reticle.visible = not overlay.visible and is_instance_valid(arena.player) and arena.player.alive
	if is_instance_valid(arena.rig):
		reticle.position = arena.rig.cursor_position
	reticle.queue_redraw()
	countdown_label.text = str(ceili(arena.countdown)) if arena.countdown >= 0 and not overlay.visible else ""
	if not is_instance_valid(arena.player):
		combat_panel.hide()
		return
	combat_panel.show()
	var f: RiftFighter = arena.player
	var living: Array[int] = arena.living_counts()
	top.text = "R I F T    /    3 × 3             AZUL  %d   ×   %d  CORAL             %02d:%02d    ·    RODADA %02d" % [living[0],living[1],int(arena.elapsed/60),int(arena.elapsed)%60,arena.round_number]
	hp_label.text = "%s  ·  %d / %d" % [f.stats.name,ceili(f.hp),int(f.max_hp)]
	hp_bar.max_value = f.max_hp
	hp_bar.value = f.hp
	hp_label.modulate = Color("ff9887") if f.hit_flash > 0 else Color("e5eadf")
	passive_label.text = "%s  %.0fs" % [RiftRules.PASSIVES[f.passive],f.passive_time] if f.passive >= 0 else "SEM BÔNUS PASSIVO"
	skill_labels[0].text = "CLIQUE · Ataque\n"+("Pronto" if f.basic_clock <= 0 else "%.1fs" % f.basic_clock)
	for i in 3:
		skill_labels[i+1].text = ["Q","E","R"][i]+" · "+f.stats.skills[i]+"\n"+("Pronto" if f.cooldowns[i] <= 0 else "%.1fs" % f.cooldowns[i])
	skill_labels[4].text = "F · "+(RiftRules.ACTIVES[f.active_rune]+"\n%.0fs para usar" % f.active_time if f.active_rune >= 0 else "Runa ativa\nEspaço vazio")
	for i in 5:
		var remaining: float = f.basic_clock if i == 0 else (f.cooldowns[i-1] if i < 4 else 0.0)
		var maximum: float = f.stats.interval if i == 0 else (f.stats.cooldowns[i-1] if i < 4 else RiftRules.RUNE_HOLD)
		var available: bool = f.alive and (remaining <= 0 if i < 4 else f.active_rune >= 0)
		var preparing: bool = i > 0 and f.preparing == i-1
		skill_bars[i].value = 1-clampf(remaining/maximum,0,1) if i < 4 else clampf(f.active_time/RiftRules.RUNE_HOLD,0,1)
		skill_styles[i].border_color = Color("e5c781") if preparing else (Color("548d80") if available else Color("303d3d"))
		skill_labels[i].modulate = Color("f1e6c9") if preparing else (Color("dfebe4") if available else Color("83948d"))
	if get_tree().paused:
		return
	hit_time = maxf(0,hit_time-dt)
	notification_time = maxf(0,notification_time-dt)
	if not f.alive:
		info.text = "ELIMINADO · OBSERVANDO ALIADO · TAB PARA TROCAR"
	elif not arena.practice_mode and arena.elapsed >= RiftRules.ZONE_START and not arena.inside_zone(f.global_position):
		info.text = "FORA DA ÁREA SEGURA · VOLTE AO CENTRO!"
	elif f.preparing >= 0 and f.movement_preview_blocked:
		info.text = "TRAJETO BLOQUEADO · MUDE A DIREÇÃO OU CANCELE"
	elif f.preparing >= 0:
		info.text = "PRÉVIA %s · SOLTAR CANCELA · USE SEM SHIFT PARA ATIVAR" % (f.stats.skills[f.preparing] if f.preparing < 3 else RiftRules.ACTIVES[f.active_rune])
	elif f.aim_obstructed:
		info.text = "COBERTURA BLOQUEIA O ATAQUE · MUDE DE POSIÇÃO"
	elif notification_time > 0:
		info.text = toast_message
	elif arena.practice_mode:
		info.text = "TREINO · ESPAÇO: MOBILIDADE · ALVOS RESTAURAM VIDA · ESC: MENU"
	elif arena.elapsed >= RiftRules.ZONE_START:
		info.text = "ZONA DE PERIGO · FIQUE NA ÁREA SEGURA" if arena.inside_zone(f.global_position) else "FORA DA ÁREA SEGURA · VOLTE AO CENTRO!"
	elif arena.elapsed >= RiftRules.ZONE_START-10:
		info.text = "ZONA FECHA EM %ds" % ceili(RiftRules.ZONE_START-arena.elapsed)
	elif arena.next_runes-arena.elapsed <= RiftRules.RUNE_WARNING:
		info.text = "RUNAS SURGEM EM %ds · PONTOS SINALIZADOS" % ceili(arena.next_runes-arena.elapsed)
	else:
		info.text = "Runas em %ds   ·   Zona em %ds" % [ceili(arena.next_runes-arena.elapsed),ceili(RiftRules.ZONE_START-arena.elapsed)]

func draw_reticle() -> void:
	var color := Color("e6efdf")
	if is_instance_valid(arena.player) and arena.player.alive and is_instance_valid(arena.rig):
		if arena.player.aim_obstructed:
			color = Color("ffb58c")
		var hit: Dictionary = arena.rig.aim_query()
		if hit.get("collider") is RiftFighter and hit.collider.team != arena.player.team:
			color = Color("ffb58c")
	reticle.draw_circle(Vector2.ZERO,3,Color(.02,.04,.03,.9))
	reticle.draw_circle(Vector2.ZERO,1.5,color)
	for direction in [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]:
		reticle.draw_line(direction*7,direction*12,Color(.02,.04,.03,.8),4,true)
		reticle.draw_line(direction*7,direction*12,color,1.5,true)

	if hit_time > 0:
		for direction in [Vector2(1,1),Vector2(1,-1),Vector2(-1,1),Vector2(-1,-1)]:
			reticle.draw_line(direction*13,direction*18,Color("ffd08d") if was_blocked else Color("a4f3d0"),2,true)

func flush_preferences() -> void:
	if preferences_dirty:
		var error: Error = arena.settings.save_preferences()
		if error == OK:
			preferences_dirty = false
		else:
			notify("Não foi possível salvar os ajustes",3)

func _exit_tree() -> void:
	if preferences_dirty:
		arena.settings.save_preferences()
