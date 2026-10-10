class_name CodeInterpreter
extends RefCounted

signal output_line(text: String)
signal execution_finished(success: bool)
signal execution_error(line_num: int, message: String)

const MAX_STEPS := 1000
var _context: Dictionary = {}
var _output_lines: PackedStringArray = []
var _had_error := false
var _steps := 0

func execute(source_code: String, context: Dictionary = {}) -> void:
	_context = context.duplicate(true)
	_output_lines = PackedStringArray()
	_had_error = false
	_steps = 0
	var lines := source_code.replace("\r", "").split("\n")
	for i: int in range(lines.size()):
		if _had_error: break
		var raw: String = lines[i]
		var line := raw.strip_edges()
		if line.is_empty() or line.begins_with("#"): continue
		_steps += 1
		if _steps > MAX_STEPS:
			_emit_error(i + 1, "执行步数超过限制")
			break
		_execute_line(line, i + 1)
	if not _had_error: execution_finished.emit(true)

func stop() -> void: _had_error = true
func get_output() -> PackedStringArray: return _output_lines

func _execute_line(line: String, line_num: int) -> void:
	if line.begins_with("print(") and line.ends_with(")"):
		var inner := line.substr(6, line.length() - 7).strip_edges()
		if inner.is_empty():
			_emit_error(line_num, "print() 需要一个参数")
			return
		var value: Variant = _evaluate_expr(inner, line_num)
		if _had_error: return
		var text := str(value)
		_output_lines.append(text)
		output_line.emit(text)
	elif "=" in line and not line.begins_with("=") and not "==" in line:
		var eq_pos := line.find("=")
		var var_name := line.substr(0, eq_pos).strip_edges()
		if not _is_valid_identifier(var_name):
			_emit_error(line_num, "无效的变量名: %s" % var_name)
			return
		_context[var_name] = _evaluate_expr(line.substr(eq_pos + 1).strip_edges(), line_num)
	else:
		_emit_error(line_num, "无法识别的语句: %s" % line)

func _evaluate_expr(expr: String, line_num: int) -> Variant:
	if _had_error: return null
	expr = expr.strip_edges()
	if (expr.begins_with("\"") and expr.ends_with("\"")) or (expr.begins_with("'") and expr.ends_with("'")):
		return expr.substr(1, expr.length() - 2)
	if expr.is_valid_int(): return expr.to_int()
	if expr.is_valid_float(): return expr.to_float()
	if expr == "True": return true
	if expr == "False": return false
	if _context.has(expr): return _context[expr]
	for op in ["==", "+", "-", "*", "/"]:
		var pos := expr.find(op, 1 if op != "==" else 0)
		if pos > 0:
			var left : Variant = _evaluate_expr(expr.substr(0, pos), line_num)
			var right : Variant = _evaluate_expr(expr.substr(pos + op.length()), line_num)
			if _had_error: return null
			if op == "==": return left == right
			if op == "+":
				if left is String or right is String: return str(left) + str(right)
				var sum := float(left) + float(right)
				return int(sum) if is_equal_approx(sum, round(sum)) else sum
			if op == "-":
				var difference := float(left) - float(right)
				return int(difference) if is_equal_approx(difference, round(difference)) else difference
			if op == "*":
				var product := float(left) * float(right)
				return int(product) if is_equal_approx(product, round(product)) else product
			if op == "/": return float(left) / float(right) if float(right) != 0 else 0
	_emit_error(line_num, "无法解析表达式: %s" % expr)
	return null

func _is_valid_identifier(name: String) -> bool:
	var regex := RegEx.new()
	regex.compile("^[a-zA-Z_][a-zA-Z0-9_]*$")
	return regex.search(name) != null

func _emit_error(line_num: int, message: String) -> void:
	_had_error = true
	execution_error.emit(line_num, message)
	execution_finished.emit(false)
