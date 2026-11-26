# Kort forklaring til presentasjonen:
# Dette skriptet styrer selve portalen. Den er låst når nivået starter.
# Når level_flow sier at nivået er ferdig, åpner set_unlocked portalen og endrer fargen og teksten.
# Portalen bruker en Area2D, altså et område som oppdager at spilleren går inn.
# Hvis portalen er åpen og spilleren er i live, sender den signalet entered til level_flow.
# Variabelen used hindrer at signalet sendes flere ganger. Det er level_flow som ber om å bytte nivå.

# Використовуємо зону, яка визначає, які фізичні об’єкти перебувають усередині порталу.
extends Area2D

# Оголошуємо сигнал входу в портал; інший скрипт отримує його та перемикає рівень.
signal entered
# Зберігаємо стан порталу: спочатку він закритий.
var unlocked = false
# Запам’ятовуємо, чи портал уже спрацював, щоб не запускати перехід повторно.
var used = false

# Функція отримує логічне значення: відкрити або закрити портал; результат не повертається.
func set_unlocked(value: bool) -> void:
	# Якщо потрібний стан уже встановлений, завершуємо функцію без повторного оновлення.
	if unlocked == value: return
	# Записуємо новий стан порталу.
	unlocked = value
	# Знаходимо дочірню заслінку й приховуємо її при відкритті; при закритті показуємо.
	$Shutter.visible = not value
	# Для відкритого порталу задаємо зелено-блакитний колір лампи, для закритого — помаранчевий.
	$Lamp.color = Color("83c4bb") if value else Color("b37746")
	# Для відкритого порталу робимо внутрішню частину зеленою, для закритого — темною.
	$Opening.color = Color("427e78") if value else Color("0c0d0f")
	# Показуємо напис про наступний рівень або про те, що портал замкнений.
	$Label.text = "NESTE NIVÅ →" if value else "LÅST"

# На кожному фізичному кроці перевіряємо вхід; параметр часу тут навмисно не використовуємо.
func _physics_process(_delta: float) -> void:
	# Якщо портал закритий або вже спрацював, одразу завершуємо перевірку.
	if not unlocked or used: return
	# По черзі перевіряємо фізичні об’єкти, які перебувають у зоні порталу.
	for body in get_overlapping_bodies():
		# Пропускаємо далі лише об’єкт із групи гравця, який ще живий.
		if body.is_in_group("player") and not body.dead:
			# Позначаємо портал використаним, щоб наступна перевірка не повторила перехід.
			used = true
			# Надсилаємо сигнал: гравець зайшов у портал; сам рівень перемикається в іншому скрипті.
			entered.emit()
			# Завершуємо функцію після успішного входу гравця.
			return
