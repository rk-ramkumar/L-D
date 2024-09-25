extends Node

# Arrays of random_name components
var prefixes = ["Ari", "Bella", "Cai", "Daro", "Elan", "Fio", "Gara", "Hali", "Anbu", "Thiru", "Raja", "Deva", "Kavi"]
var suffixes = ["dor", "lina", "mir", "ron", "na", "eth", "sor", "vin", "nathan", "kumar", "muthu", "mani", "selvan"]
var middles = ["an", "al", "ir", "os", "ur", "ar", "kan", "in", "esh", "ni"]

# Function to generate a random random_name
func generate_name(generated_names = {}) -> String:
	var random_name = ""
	var attempts = 0

	# Loop to ensure uniqueness
	while attempts < 100:  # Limit the number of attempts to avoid infinite loops
		var prefix = prefixes[randi() % prefixes.size()]
		var suffix = suffixes[randi() % suffixes.size()]

		# Random chance to add a middle part for more variety
		if randf() < 0.3:  # 30% chance to add a middle part
			var middle = middles[randi() % middles.size()]
			random_name = prefix + middle + suffix
		else:
			random_name = prefix + suffix

		# Check if the random_name is unique
		if not generated_names.has(random_name):
			generated_names[random_name] = true
			return random_name

		attempts += 1

	return random_name  # Fallback message

# Function to generate multiple unique names
func generate_unique_names(count: int) -> Array:
	var unique_names = []
	var _generated_names = {}
	for i in range(count):
		var new_name = generate_name()
		unique_names.append(new_name)
	return unique_names

func _ready():
	randomize()
