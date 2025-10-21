class_name ArrayUtils

# 2次元配列を実現するためのユーティリティ関数群
static func create_2d_array(width: int, height: int, default_value: Variant) -> Array:
    var array: Array = []
    for y in range(height):
        var row: Array = []
        for x in range(width):
            row.append(default_value)
        array.append(row)
    return array

# 値のセットと取得
static func set_2d_array_value(array: Array, x: int, y: int, value: Variant) -> void:
    if y >= 0 and y < array.size() and x >= 0 and x < array[y].size():
        array[y][x] = value
static func get_2d_array_value(array: Array, x: int, y: int) -> Variant:
    if y >= 0 and y < array.size() and x >= 0 and x < array[y].size():
        return array[y][x]
    return null