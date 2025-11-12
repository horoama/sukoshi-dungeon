extends Node
class_name Log

enum LogLevel {
    DEBUG,
    INFO,
    WARN,
    ERROR,
}

func log_level_to_string(l: int) -> String:
    match l:
        LogLevel.DEBUG:
            return "DEBUG"
        LogLevel.INFO:
            return "INFO"
        LogLevel.WARN:
            return "WARN"
        LogLevel.ERROR:
            return "ERROR"
        _:
            return "UNKNOWN"

# 最低ログレベル（このレベルより低いログは出力しない）
var min_level: int = LogLevel.DEBUG

# 有効なカテゴリのセット。空配列は全カテゴリ有効を意味する
var enabled_categories: Array = []

# file logging
var file_logging_enabled: bool = false
var file_path: String = "user://logs/log.txt"

func _ready():
    # ノードとして使うときの初期化フック（autoload に入れた場合ここが呼ばれます）
    pass

func set_min_level(level: int) -> void:
    min_level = level

func enable_category(cat: int) -> void:
    if cat in enabled_categories:
        return
    enabled_categories.append(cat)

func disable_category(cat: int) -> void:
    if cat in enabled_categories:
        enabled_categories.erase(cat)

func is_category_enabled(cat: int) -> bool:
    return enabled_categories.size() == 0 or (cat in enabled_categories)

func enable_file_logging(path: String = "user://logs/log.txt") -> void:
    # Placeholder: enable file logging. Implementation depends on Godot version (File/DirAccess API).
    # Set flags here; actual write implementation can be added later.
    file_logging_enabled = true
    file_path = path

func disable_file_logging() -> void:
    file_logging_enabled = false

func log_message(level: int, message, stack: Dictionary) -> void:
    # フィルタ
    if level < min_level:
        return
    var text := _format(level, message, stack)
    print(text)
    if file_logging_enabled:
        pass

func debug(message) -> void:
    var stack = get_stack()[1]
    log_message(LogLevel.DEBUG, message, stack)

func info(message) -> void:
    var stack = get_stack()[1]
    log_message(LogLevel.INFO, message, stack)

func warn(message) -> void:
    var stack = get_stack()[1]
    log_message(LogLevel.WARN, message, stack)

func error(message) -> void:
    var stack = get_stack()[1]
    log_message(LogLevel.ERROR, message, stack)

func _format(level: int, message, stack: Dictionary) -> String:
    var lvl := log_level_to_string(level)
    return "[%s] [%s] [func:%s] %s" % [lvl, stack["source"].get_file(), stack["function"], str(message)]