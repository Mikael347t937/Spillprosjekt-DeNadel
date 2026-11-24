# Використовуємо звичайний вузол для керування звуками без графіки та фізики.
extends Node

# Коли вузол готовий, завантажуємо ресурс звуку пістолета; сам звук ще не відтворюється.
@onready var PISTOL: AudioStream = load("res://assets/audio/pistol.wav")
# Коли вузол готовий, завантажуємо ресурс звуку рушниці.
@onready var SHOTGUN: AudioStream = load("res://assets/audio/shotgun.wav")
# Коли вузол готовий, завантажуємо ресурс звуку влучання або удару.
@onready var IMPACT: AudioStream = load("res://assets/audio/impact.wav")
# Коли вузол готовий, завантажуємо ресурс звуку підбирання предметів.
@onready var PICKUP: AudioStream = load("res://assets/audio/pickup.wav")

# Функція отримує звук і гучність у децибелах; стандартна гучність — мінус вісім децибел.
func play_effect(stream: AudioStream, volume_db: float = -8.0) -> void:
	# Не запускаємо новий ефект під час паузи або в режимі автоматичних перевірок без вікна.
	if get_tree().paused or DisplayServer.get_name() == "headless": return
	# Створюємо окремий програвач, щоб кілька звукових ефектів могли звучати одночасно.
	var voice = AudioStreamPlayer.new()
	# Передаємо створеному програвачу вибраний звуковий ресурс.
	voice.stream = stream
	# Задаємо гучність програвача; більш від’ємне значення означає тихіший звук.
	voice.volume_db = volume_db
	# Дозволяємо вже запущеному звуку завершитися, навіть якщо гру поставлять на паузу.
	voice.process_mode = Node.PROCESS_MODE_ALWAYS
	# Додаємо програвач дочірнім вузлом, щоб він став частиною дерева сцени.
	add_child(voice)
	# З’єднуємо сигнал завершення звуку з безпечним видаленням програвача.
	voice.finished.connect(voice.queue_free)
	# Починаємо відтворення вибраного звуку.
	voice.play()

# Коли цей вузол виходить із дерева сцени, очищаємо програвачі, які ще залишилися.
func _exit_tree() -> void:
	# По черзі перебираємо всі дочірні програвачі звуку.
	for voice in get_children():
		# Зупиняємо відтворення поточного програвача.
		voice.stop()
		# Прибираємо посилання програвача на звуковий ресурс; файл на диску залишається.
		voice.stream = null
