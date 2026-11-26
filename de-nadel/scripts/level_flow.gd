# Kort forklaring til presentasjonen:
# Dette skriptet passer på når et nivå er ferdig, og når spilleren kan gå videre.
# Det sjekker om fiendebølgene er ferdige, om alle fiendene er døde og om oppdraget er gjort.
# På første nivå må vi også finne haglen, og på andre nivå må vi hente lagerlisten.
# Når alt er klart, åpnes portalen. Når spilleren går inn, lagres våpen, patroner og mynter før vi bytter nivå.
# På siste nivå åpnes buret før seiersmenyen vises. Variabelen completed hindrer at avslutningen starter flere ganger.

# Скрипт успадковує Node2D і керує завершенням рівня, а не рухом персонажа.
extends Node2D

# В Inspector можна вибрати файл наступної сцени .tscn; порожній рядок означає, що наступного рівня немає.
@export_file("*.tscn") var next_level = ""
# Створюємо список завдань в Inspector: 0 — лише бій, 1 — знайти рушницю, 2 — забрати складський список.
@export_enum("Kamp", "Finn haglen", "Hent lagerlisten") var objective = 0
# Зберігаємо назву розділу, яку показуватимемо в тексті завдання.
@export var chapter = ""
# Дозволяємо записати в Inspector опис завдання з кількох рядків.
@export_multiline var briefing = ""
# Спочатку складський список не зібраний; скрипт предмета змінює це значення на true після підбирання.
var supplies_collected = false

# Після підготовки дочірніх вузлів зберігаємо посилання на GameHUD — інтерфейс цього рівня.
@onready var hud = $GameHUD
# Знаходимо керівник хвиль, якщо він є; за його відсутності отримуємо null, а не помилку пошуку.
@onready var waves = get_node_or_null("WaveManager")
# Запам’ятовуємо, чи рівень уже завершений, щоб не запускати його фінал щокадру.
var completed = false

# Godot викликає цю функцію один раз, коли рівень і його дочірні вузли готові.
func _ready() -> void:
	# Якщо є вузол Portal, підключаємо його сигнал entered до нашої функції enter_portal.
	if has_node("Portal"): $Portal.entered.connect(enter_portal)

# Ця функція спрацьовує за сигналом входу в портал і запускає перехід на наступний рівень.
func enter_portal() -> void:
	# У дереві сцени знаходимо перший вузол у групі player — нашого гравця.
	var player = get_tree().get_first_node_in_group("player")
	# Нічого не робимо, якщо рівень ще не завершений, перехід уже триває, гра програна або гравець мертвий.
	if not completed or hud.changing_scene or hud.game_over or player.dead: return
	# Зберігаємо монети, зброю й боєприпаси гравця в спільному RunInventory перед зміною сцени.
	RunInventory.save_player(player)
	# Просимо HUD перейти до сцени, шлях до якої записаний у next_level; саму зміну сцени виконує HUD.
	hud.leave_for(next_level)

# Godot викликає цю функцію кожного кадру; _delta — час між кадрами, який тут не потрібний.
func _process(_delta: float) -> void:
	# Зупиняємо перевірку, якщо завершення вже оброблене, гравець програв або почалася зміна сцени.
	if completed or hud.game_over or hud.changing_scene: return
	# Оновлюємо текст завдання та кількість живих ворогів.
	update_objective()
	# Якщо керівник хвиль існує, чекаємо, доки він позначить хвилі завершеними; без нього йдемо далі.
	if waves and not waves.finished: return
	# Перебираємо всі вузли групи enemies, зокрема ворогів, доданих під час гри.
	for enemy in get_tree().get_nodes_in_group("enemies"):
		# Якщо хоча б один ворог живий, виходимо з усієї функції: рівень ще не виграний.
		if not enemy.dead: return
	# Перевіряємо додаткове завдання; якщо воно не виконане, теж чекаємо наступного кадру.
	if not objective_ready(): return
	# Усі умови виконані: позначаємо рівень завершеним до запуску фіналу, щоб не повторити його.
	completed = true
	# Викликаємо функцію, яка відкриє портал або запустить кінцівку останнього рівня.
	finish_level()

# Окрема функція визначає, що показати після виконання всіх умов рівня.
func finish_level() -> void:
	# Якщо в рівні є портал і задано наступну сцену, використовуємо перехід через портал.
	if has_node("Portal") and not next_level.is_empty():
		# Відкриваємо портал через його метод set_unlocked; далі він сам перевірятиме вхід гравця.
		$Portal.set_unlocked(true)
		# Змінюємо текст цілі в HUD на норвезький напис «Портал відкритий →».
		hud.get_node("Screen/Objective/Content/Goal").text = "Portalen er åpen →"
		# Виходимо з функції: для цього рівня не потрібно запускати клітку та фінальне меню.
		return
	# Збираємо всі вузли групи supply_cages — клітки зі шприцами для фінальної сцени.
	var cages = get_tree().get_nodes_in_group("supply_cages")
	# Якщо знайшли хоча б одну клітку, спершу запускаємо фінальну анімацію.
	if not cages.is_empty():
		# Повідомляємо HUD, що вже триває кінцівка; інтерфейс враховує цей стан.
		hud.ending = true
		# Знаходимо гравця та запускаємо begin_ending(), щоб зупинити його й захистити під час фіналу.
		get_tree().get_first_node_in_group("player").begin_ending()
		# Ставимо всі ворожі снаряди в чергу на видалення, щоб вони не залишалися в кінцівці.
		for projectile in get_tree().get_nodes_in_group("enemy_projectiles"): projectile.queue_free()
		# По черзі перебираємо клітки, якщо на рівні їх кілька.
		for cage in cages:
			# Запускаємо відкриття поточної клітки й чекаємо завершення release_supplies(); гра при цьому не зависає.
			await cage.release_supplies()
			# Після очікування перевіряємо, чи рівень ще в дереві сцени; якщо ні, припиняємо цю функцію.
			if not is_inside_tree(): return
		# Повторно перевіряємо наявність рівня перед зверненням до його HUD після циклу з очікуваннями.
		if not is_inside_tree(): return
	# Показуємо екран перемоги: передаємо шлях наступного рівня та ознаку того, що на рівні були клітки.
	hud.show_victory(next_level, not cages.is_empty())

# Функція повертає bool: true, коли додаткове завдання виконане, або false, коли ще ні.
func objective_ready() -> bool:
	# Знаходимо гравця, щоб перевірити, чи він уже має рушницю.
	var player = get_tree().get_first_node_in_group("player")
	# Для завдання 1 потрібен наявний гравець із has_shotgun = true; and не читає властивість у null.
	if objective == 1: return player != null and player.has_shotgun
	# Для завдання 2 повертаємо стан supplies_collected: чи підібрано складський список.
	if objective == 2: return supplies_collected
	# Для завдання 0 додаткових предметів не потрібно, тому повертаємо true; вороги перевіряються окремо.
	return true

# Ця функція формує й оновлює текст завдання в інтерфейсі.
func update_objective() -> void:
	# Починаємо підрахунок живих ворогів з нуля.
	var enemies_left = 0
	# Перебираємо всіх ворогів із групи enemies.
	for enemy in get_tree().get_nodes_in_group("enemies"):
		# Додаємо один до лічильника тільки для живого ворога.
		if not enemy.dead: enemies_left += 1
	# Формуємо норвезький текст «Вартові: число»; %d підставляє ціле число enemies_left.
	var task = "Vakter: %d" % enemies_left
	# Якщо обрано завдання 1 і рушниці ще немає, дописуємо підказку знайти її.
	if objective == 1 and not objective_ready(): task += " · Finn haglen."
	# Якщо обрано завдання 2 і список ще не зібраний, дописуємо підказку знайти складський список.
	if objective == 2 and not supplies_collected: task += " · Finn lagerlisten."
	# Записуємо назву розділу chapter у вузол Title панелі завдання.
	hud.get_node("Screen/Objective/Content/Title").text = chapter
	# Записуємо підготовлений текст із ворогами та ціллю у вузол Goal.
	hud.get_node("Screen/Objective/Content/Goal").text = task
	# Записуємо опис briefing у вузол Story; цей текст можна змінювати через Inspector.
	hud.get_node("Screen/Objective/Content/Story").text = briefing
