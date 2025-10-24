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

# 便利な関数たち
static func print_2d_array(array: Array) -> void:
    for row in array:
        var row_str = ""
        for item in row:
            row_str += str(item) + " "
        print(row_str)

static func fill_2d_array(array: Array, value: Variant) -> void:
    for y in range(array.size()):
        for x in range(array[y].size()):
            array[y][x] = value

static func copy_2d_array(array: Array) -> Array:
    var new_array: Array = []
    for row in array:
        var new_row: Array = []
        for item in row:
            new_row.append(item)
        new_array.append(new_row)
    return new_array