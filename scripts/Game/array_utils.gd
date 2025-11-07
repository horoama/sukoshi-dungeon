class_name ArrayUtils

# 2次元配列を実現するためのユーティリティ関数群
static func create_2d_array(width: int, height: int, default_value: Variant) -> Array:
    var array: Array = []
    # array[x][y] の形でアクセスするために内側の配列を作成
    for x in range(width):
        var column: Array = []
        for y in range(height):
            column.append(default_value)
        array.append(column)
    return array