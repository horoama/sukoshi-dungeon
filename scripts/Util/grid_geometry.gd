class_name GridGeometry
extends RefCounted
# グリッド上の幾何学計算を行うユーティリティクラス

# ブレゼンハムのアルゴリズムを使用して、始点から終点までの直線を構成する座標の配列を返します。
#
# @param start: 始点
# @param end: 終点
# @return: 始点から終点までの座標の配列（始点と終点を含む）
static func get_line(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
    var points: Array[Vector2i] = []

    var x0 = start.x
    var y0 = start.y
    var x1 = end.x
    var y1 = end.y

    var dx = abs(x1 - x0)
    var dy = abs(y1 - y0)
    var sx = 1 if x0 < x1 else -1
    var sy = 1 if y0 < y1 else -1
    var err = dx - dy

    while true:
        points.append(Vector2i(x0, y0))

        if x0 == x1 and y0 == y1:
            break

        var e2 = 2 * err
        if e2 > -dy:
            err -= dy
            x0 += sx
        if e2 < dx:
            err += dx
            y0 += sy

    return points
