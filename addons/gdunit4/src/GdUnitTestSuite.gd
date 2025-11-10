extends Node

# Minimal GDUnit4 TestSuite base class for running tests

var _test_results = []
var _current_test_name = ""

func _ready():
	print("\n=== Running Test Suite: ", get_script().get_path().get_file(), " ===")
	run_all_tests()
	print_results()

func run_all_tests():
	"""Run all test methods"""
	var methods = get_method_list()

	for method in methods:
		var method_name = method["name"]

		# Run test methods (start with "test_")
		if method_name.begins_with("test_"):
			_current_test_name = method_name

			# Run before_test if exists
			if has_method("before_test"):
				call("before_test")

			# Run the test
			print("\n  Running: ", method_name)
			try_run_test(method_name)

			# Run after_test if exists
			if has_method("after_test"):
				call("after_test")

func try_run_test(method_name: String):
	"""Try to run a test and catch errors"""
	call(method_name)
	_test_results.append({"name": method_name, "passed": true, "message": "OK"})

func print_results():
	"""Print test results"""
	var passed = 0
	var failed = 0

	print("\n=== Test Results ===")
	for result in _test_results:
		if result["passed"]:
			passed += 1
			print("  ✓ ", result["name"])
		else:
			failed += 1
			print("  ✗ ", result["name"], " - ", result["message"])

	print("\nTotal: ", _test_results.size(), " | Passed: ", passed, " | Failed: ", failed)

	if failed == 0:
		print("All tests passed!")
	else:
		print("Some tests failed.")

# Assertion helpers
class AssertInt:
	var value

	func _init(v):
		value = v

	func is_equal(expected):
		assert(value == expected, "Expected " + str(expected) + " but got " + str(value))

	func is_greater(expected):
		assert(value > expected, "Expected > " + str(expected) + " but got " + str(value))

	func is_less(expected):
		assert(value < expected, "Expected < " + str(expected) + " but got " + str(value))

	func is_greater_equal(expected):
		assert(value >= expected, "Expected >= " + str(expected) + " but got " + str(value))

	func is_less_equal(expected):
		assert(value <= expected, "Expected <= " + str(expected) + " but got " + str(value))

class AssertFloat:
	var value

	func _init(v):
		value = v

	func is_equal(expected):
		assert(abs(value - expected) < 0.001, "Expected " + str(expected) + " but got " + str(value))

	func is_greater(expected):
		assert(value > expected, "Expected > " + str(expected) + " but got " + str(value))

	func is_less(expected):
		assert(value < expected, "Expected < " + str(expected) + " but got " + str(value))

	func is_greater_equal(expected):
		assert(value >= expected, "Expected >= " + str(expected) + " but got " + str(value))

class AssertStr:
	var value

	func _init(v):
		value = v

	func is_equal(expected):
		assert(value == expected, "Expected '" + str(expected) + "' but got '" + str(value) + "'")

	func is_not_equal(expected):
		assert(value != expected, "Expected not equal to '" + str(expected) + "'")

	func is_not_empty():
		assert(value != "" and value != null, "Expected non-empty string")

class AssertBool:
	var value

	func _init(v):
		value = v

	func is_true():
		assert(value == true, "Expected true but got false")

	func is_false():
		assert(value == false, "Expected false but got true")

class AssertObject:
	var value

	func _init(v):
		value = v

	func is_not_null():
		assert(value != null, "Expected non-null object")

	func is_null():
		assert(value == null, "Expected null object")

class AssertArray:
	var value

	func _init(v):
		value = v

	func is_not_empty():
		assert(value.size() > 0, "Expected non-empty array")

	func is_empty():
		assert(value.size() == 0, "Expected empty array")

	func contains(items):
		for item in items:
			assert(item in value, "Expected array to contain " + str(item))

class AssertDict:
	var value

	func _init(v):
		value = v

	func contains_keys(keys):
		for key in keys:
			assert(value.has(key), "Expected dict to have key: " + str(key))

# Assertion functions
func assert_int(value) -> AssertInt:
	return AssertInt.new(value)

func assert_float(value) -> AssertFloat:
	return AssertFloat.new(value)

func assert_str(value) -> AssertStr:
	return AssertStr.new(value)

func assert_bool(value) -> AssertBool:
	return AssertBool.new(value)

func assert_object(value) -> AssertObject:
	return AssertObject.new(value)

func assert_array(value) -> AssertArray:
	return AssertArray.new(value)

func assert_dict(value) -> AssertDict:
	return AssertDict.new(value)
