extends Node2D

@onready var start_fishing_button = $UI/Container/StartFishingButton
@onready var progress_soal = $UI/KotakSoal/ProgressSoal
@onready var timer_soal = $UI/KotakSoal/TimerSoal/Timer
@onready var kotak_soal = $UI/KotakSoal
@onready var input_soal = $UI/KotakSoal/VBoxContainer/InputSoal
@onready var soal = $UI/KotakSoal/VBoxContainer/Soal
@onready var fish_state = $UI/FishStateContainer/FishState
@onready var oke_dapet_ikan_button = $UI/NotifDapetIkan/VBoxContainer/OkeDapetIkanButton
@onready var teks_dapet_ikan = $UI/NotifDapetIkan/VBoxContainer/TeksDapetIkan
@onready var kotak_notif_dapet_ikan = $UI/NotifDapetIkan
@onready var player = $Player

var questions: Array[Dictionary] = [
	{
		"question": "1 + 1",
		"answer": 2
	},
	{
		"question": "5 + 3",
		"answer": 8
	},
	{
		"question": "10 - 4",
		"answer": 6
	},
	{
		"question": "7 + 8",
		"answer": 15
	},
	{
		"question": "12 - 5",
		"answer": 7
	},
	{
		"question": "3 x 4",
		"answer": 12
	},
	{
		"question": "15 + 5",
		"answer": 20
	},
	{
		"question": "20 - 9",
		"answer": 11
	},
	{
		"question": "6 x 2",
		"answer": 12
	},
	{
		"question": "10 : 2",
		"answer": 5
	},
	{
		"question": "9 + 6",
		"answer": 15
	},
	{
		"question": "18 - 10",
		"answer": 8
	},
	{
		"question": "5 x 5",
		"answer": 25
	},
	{
		"question": "16 : 4",
		"answer": 4
	},
	{
		"question": "14 + 7",
		"answer": 21
	},
	{
		"question": "25 - 12",
		"answer": 13
	},
	{
		"question": "4 x 6",
		"answer": 24
	},
	{
		"question": "21 : 3",
		"answer": 7
	},
	{
		"question": "11 + 13",
		"answer": 24
	},
	{
		"question": "30 - 15",
		"answer": 15
	}
]

var fishes: Array[Dictionary] = [
	{
		"name": "Nemo",
		"rarity": "Common"
	},
	{
		"name": "Bandeng",
		"rarity": "Rare"
	},
	{
		"name": "Lele",
		"rarity": "Legendary"
	},
	{
		"name": "sapu-sapu",
		"rarity": "common"
	},
	{
		"name": "cupang",
		"rarity": "common"
	},
	{
		"name": "gurita",
		"rarity": "Rare"
	},
]

var new_questions: Array[Dictionary]
var question_index: int = 0
var waiting_for_fish_time: SceneTreeTimer
var wait_time 


var start_fishing := false
var waiting_for_fish := false
var fish_biting := false
var fishing_success := false
var fishing_failed := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_fishing_button.pressed.connect(_on_start_fishing_button_pressed)
	input_soal.text_submitted.connect(_check_answer)
	oke_dapet_ikan_button.pressed.connect(_on_oke_dapet_ikan_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if waiting_for_fish:
		fish_state.text = "Mulai mancing\n" + str(int(wait_time - waiting_for_fish_time.time_left))

func _on_start_fishing_button_pressed() -> void:
	start_fishing = true
	waiting_for_fish = true
	start_fishing_button.visible = false
	fish_state.text = "Mulai mancing"
	_on_start_fishing()

	
func _on_start_fishing():
	_on_waiting_for_fish()
	
		
func _on_waiting_for_fish() -> void:
	var get_fish = 0
	
	if waiting_for_fish == true:
		waiting_for_fish_time = get_tree().create_timer(randi_range(4, 10))
		wait_time = waiting_for_fish_time.time_left
		await waiting_for_fish_time.timeout
		waiting_for_fish = false
		get_fish = randi_range(0, 1)
	
	if get_fish == 1:
		_on_fish_biting()
		fish_state.text = "Ikan memakan umpan!"
	else:
		waiting_for_fish = false
		start_fishing = false
		start_fishing_button.visible = true
		
		fish_state.text = "Gagal dapet ikan"
		
func _on_fish_biting() -> void:
		fish_biting = true
		waiting_for_fish = false
		_display_questions()
		
func _display_questions():
	if question_index > 4:
		question_index = 0
		kotak_soal.visible = false
		return
	print(question_index)
	if new_questions.size() == 0:
		new_questions = [
			questions[randi_range(0,19)],
			questions[randi_range(0,19)],
			questions[randi_range(0,19)],
			questions[randi_range(0,19)],
			questions[randi_range(0,19)],
		]
	
	soal.text = new_questions[question_index].question
	
	kotak_soal.visible = true
	input_soal.grab_focus()
	


func _check_answer(answer: String):
	if int(answer) == new_questions[question_index].answer:
		fish_state.text = "Benar"
		progress_soal.text = str(question_index + 1) + "/5"
		input_soal.text = ""
		input_soal.edit()
		
		if question_index > 3:
			_get_fish()
			return
		question_index += 1
		_display_questions()
	else:
		start_fishing = false
		fish_biting = false
		kotak_soal.visible = false
		question_index = 0
		progress_soal.text = "1/5"
		fish_state.text = "Salah: ikan lepas"
		
func _get_fish():
	start_fishing = false
	fish_biting = false
	kotak_soal.visible = false
	question_index = 0
	progress_soal.text = "1/5"
	
	var random_index = randi_range(0, fishes.size() - 1)
	var fish = fishes[random_index]
	
	fish_state.text = ""
	teks_dapet_ikan.text = "Kamu Berhasil mendapatkan ikan!\n" + fish.name + " - " + fish.rarity
	kotak_notif_dapet_ikan.visible = true

func _on_oke_dapet_ikan_button_pressed() -> void:
	kotak_notif_dapet_ikan.visible = false
	start_fishing_button.visible = true
	
