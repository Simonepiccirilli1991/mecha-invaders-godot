extends CanvasLayer

# Mecha Selection Screen - allows player to choose their mecha

signal mecha_selected

# Current selection index
var current_selection: int = 3  # Default to BALANCED (index 3)
var mecha_types: Array

# UI References
@onready var title_label = $VBoxContainer/TitleLabel
@onready var mecha_grid = $VBoxContainer/MechaGrid
@onready var stat_panel = $VBoxContainer/StatPanel
@onready var mecha_name_label = $VBoxContainer/StatPanel/StatsVBox/MechaNameLabel
@onready var description_label = $VBoxContainer/StatPanel/StatsVBox/DescriptionLabel
@onready var speed_bar = $VBoxContainer/StatPanel/StatsVBox/SpeedHBox/SpeedBar
@onready var firerate_bar = $VBoxContainer/StatPanel/StatsVBox/FireRateHBox/FireRateBar
@onready var armor_bar = $VBoxContainer/StatPanel/StatsVBox/ArmorHBox/ArmorBar
@onready var speed_value_label = $VBoxContainer/StatPanel/StatsVBox/SpeedHBox/SpeedValue
@onready var firerate_value_label = $VBoxContainer/StatPanel/StatsVBox/FireRateHBox/FireRateValue
@onready var armor_value_label = $VBoxContainer/StatPanel/StatsVBox/ArmorHBox/ArmorValue
@onready var instruction_label = $VBoxContainer/InstructionLabel

# Mecha card references
var mecha_cards: Array = []

func _ready() -> void:
	# Get all mecha types
	mecha_types = MechaSelector.get_all_mecha_types()
	
	# Build mecha cards
	build_mecha_cards()
	
	# Set initial selection in MechaSelector
	MechaSelector.set_selected_mecha(mecha_types[current_selection])
	
	# Update display
	update_selection_display()
	
	# Animate instruction text (blink effect)
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(instruction_label, "modulate:a", 0.3, 1.0)
	tween.tween_property(instruction_label, "modulate:a", 1.0, 1.0)

func build_mecha_cards() -> void:
	# Create a card for each mecha
	for i in range(mecha_types.size()):
		var mecha_type = mecha_types[i]
		var mecha_data = MechaSelector.get_mecha_data(mecha_type)
		
		# Create card container
		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(160, 240)
		
		# Card content
		var vbox = VBoxContainer.new()
		card.add_child(vbox)
		
		# Mecha sprite
		var sprite = TextureRect.new()
		sprite.custom_minimum_size = Vector2(128, 160)
		sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		# Load sprite texture
		var sprite_path = mecha_data["sprite_path"]
		print("MechaSelection: Loading sprite ", i, " from: ", sprite_path)
		var texture = load(sprite_path)
		if texture:
			sprite.texture = texture
			print("MechaSelection: Sprite ", i, " loaded successfully!")
		else:
			print("MechaSelection: ERROR - Failed to load sprite from ", sprite_path)
			# Create fallback colored rect if sprite fails to load
			var fallback = ColorRect.new()
			fallback.color = mecha_data["color"]
			fallback.custom_minimum_size = Vector2(128, 160)
			vbox.add_child(fallback)
		
		if texture:
			vbox.add_child(sprite)
		
		# Mecha name
		var name_label = Label.new()
		name_label.text = mecha_data["display_name"]
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(name_label)
		
		# Selection border (initially hidden)
		var border = Panel.new()
		border.name = "SelectionBorder"
		border.anchors_preset = Control.PRESET_FULL_RECT
		border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		border.visible = false
		# Add stylebox for border
		var stylebox = StyleBoxFlat.new()
		stylebox.set_border_width_all(4)
		stylebox.border_color = mecha_data["color"]
		stylebox.bg_color = Color(0, 0, 0, 0)
		border.add_theme_stylebox_override("panel", stylebox)
		card.add_child(border)
		
		# Make card clickable
		var button = Button.new()
		button.anchors_preset = Control.PRESET_FULL_RECT
		button.flat = true
		button.pressed.connect(_on_mecha_card_clicked.bind(i))
		card.add_child(button)
		
		mecha_grid.add_child(card)
		mecha_cards.append(card)

func _input(event: InputEvent) -> void:
	# Handle mecha selection with arrow keys
	if event.is_action_pressed("move_left"):
		select_previous_mecha()
	elif event.is_action_pressed("move_right"):
		select_next_mecha()
	elif event.is_action_pressed("shoot"):  # Space key
		confirm_selection()

func select_previous_mecha() -> void:
	current_selection = (current_selection - 1 + mecha_types.size()) % mecha_types.size()
	MechaSelector.set_selected_mecha(mecha_types[current_selection])
	update_selection_display()

func select_next_mecha() -> void:
	current_selection = (current_selection + 1) % mecha_types.size()
	MechaSelector.set_selected_mecha(mecha_types[current_selection])
	update_selection_display()

func select_mecha(index: int) -> void:
	if index >= 0 and index < mecha_types.size():
		current_selection = index
		MechaSelector.set_selected_mecha(mecha_types[current_selection])
		update_selection_display()

func confirm_selection() -> void:
	print("Mecha selected: ", MechaSelector.get_mecha_name())
	mecha_selected.emit()
	queue_free()

func update_selection_display() -> void:
	var mecha_data = MechaSelector.get_selected_mecha_data()
	
	# Update mecha name and description
	mecha_name_label.text = mecha_data["display_name"]
	description_label.text = mecha_data["description"]
	
	# Update stat bars
	var stats = mecha_data["stats"]
	
	# Speed: 250-600 range, normalize to 0-100
	var speed_percent = (stats["speed"] - 200) / 400.0 * 100.0
	speed_bar.value = clamp(speed_percent, 0, 100)
	speed_value_label.text = str(stats["speed"])
	
	# Fire rate: Lower is better, 0.35-0.8 range (inverted)
	var firerate_percent = (0.8 - stats["fire_rate"]) / 0.45 * 100.0
	firerate_bar.value = clamp(firerate_percent, 0, 100)
	firerate_value_label.text = str(stats["fire_rate"]) + "s"
	
	# Armor based on lives modifier: -1, 0, +1 -> convert to 33%, 66%, 100%
	var armor_percent = (stats["lives_modifier"] + 1) * 50.0
	armor_bar.value = clamp(armor_percent, 0, 100)
	var lives_mod = stats["lives_modifier"]
	if lives_mod > 0:
		armor_value_label.text = "+1 Life"
	elif lives_mod < 0:
		armor_value_label.text = "-1 Life"
	else:
		armor_value_label.text = "Normal"
	
	# Update card highlights
	for i in range(mecha_cards.size()):
		var card = mecha_cards[i]
		if i == current_selection:
			# Highlight selected card
			card.modulate = Color(1.2, 1.2, 1.2)  # Brighter
			card.get_node("SelectionBorder").visible = true
		else:
			card.modulate = Color(0.7, 0.7, 0.7)  # Dimmer
			card.get_node("SelectionBorder").visible = false

# Called when a mecha card is clicked
func _on_mecha_card_clicked(index: int) -> void:
	select_mecha(index)
