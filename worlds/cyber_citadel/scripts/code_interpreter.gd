class_name CodeInterpreter
extends RefCounted

signal output_line(text: String)
signal execution_finished(success: bool)
signal execution_error(line_num: int, message: String)

const MAX_STEPS := 1000

var _context: Dictionary = {}
var _output_lines: PackedStringArray = []
var _had_error := false

func execute(source_code: String, context: Dictionary = {}) -> void:
	_context = context
	_output_lines = PackedStringArray()
	_had_error = false

	var lines := source_code.split("\n")
	var step_count := 0

	for i: int in range(lines.size()):
		if step_count >= MAX_STEPS:
			_emit_error(i + 1, "超过最大执行步数限制（%d）" % MAX_STEPS)
			return
		var line := lines[i].strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue
		step_count += 1
		_execute_line(line, i + 1)
		if _had_error:
			return

	execution_finished.emit(true)

func stop() -> void:
	pass

func get_output() -> PackedStringArray:
	return _output_lines

func _execute_line(line: String, line_num: int) -> void:
	if line.begins_with("print(") and line.ends_with(")"):
		_exec_print(line, line_num)
	elif "=" in line and not line.begins_with("=") and not "==" in line:
		_exec_assignment(line, line_num)
	else:
		_emit_error(line_num, "无法识别的语句: %s" % line)

func _exec_print(line: String, line_num: int) -> void:
	var inner := line.substr(6, line.length() - 7).strip_edges()
	if inner.is_empty():
		_emit_error(line_num, "print() 需要一个参数")
		return
	var value: Variant = _evaluate_expr(inner, line_num)
	if _had_error:
		return
	var text := str(value)
	_output_lines.append(text)
	output_line.emit(text)

func _exec_assignment(line: String, line_num: int) -> void:
	var eq_pos := line.find("=")
	var var_name := line.substr(0, eq_pos).strip_edges()
	var expr := line.substr(eq_pos + 1).strip_edges()

	if not _is_valid_identifier(var_name):
		_emit_error(line_num, "无效的变量名: %s" % var_name)
		return

	var value: Variant = _evaluate_expr(expr, line_num)
	if _had_error:
		return
	_context[var_name] = value

func _evaluate_expr(expr: String, line_num: int) -> Variant:
	if _had_error:
		return null

	if (expr.begins_with("\"") and expr.ends_with("\"")) or \
	   (expr.begins_with("'") and expr.ends_with("'")):
		return expr.substr(1, expr.length() - 2)

	if expr.is_valid_int():
		return expr.to_int()

	if expr.is_valid_float():
		return expr.to_float()

	if expr == "True":
		return true
	if expr == "False":
		return false

	if _context.has(expr):
		return _context[expr]

	if "+" in expr:
		return _eval_binary_op(expr, "+", line_num)

	_emit_error(line_num, "无法解析表达式: %s" % expr)
	return null

func _eval_binary_op(expr: String, op: String, line_num: int) -> Variant:
	var parts := expr.split(op, true, 1)
	if parts.size() != 2:
		_emit_error(line_num, "无效的表达式: %s" % expr)
		return null
	var left: Variant = _evaluate_expr(parts[0].strip_edges(), line_num)
	var right: Variant = _evaluate_expr(parts[1].strip_edges(), line_num)
	if _had_error:
		return null

	if left is String or right is String:
		return str(left) + str(right)
	if left is int and right is int:
		return left + right
	if (left is int or left is float) and (right is int or right is float):
		return float(left) + float(right)
	return str(left) + str(right)

func _is_valid_identifier(name: String) -> bool:
	if name.is_empty():
		return false
	var regex := RegEx.new()
	regex.compile("^[a-zA-Z_][a-zA-Z0-9_]*$")
	return regex.search(name) != null

func _emit_error(line_num: int, message: String) -> void:
	_had_error = true
	execution_error.emit(line_num, message)
	execution_finished.emit(false)
