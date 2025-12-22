class_name MapConnector
extends RefCounted

static func get_neighbors(x: int, y: int, width: int, height: int) -> Array:
    var neighbors: Array = []
    for dy in [-1, 0, 1]:
        for dx in [-1, 0, 1]:
            # 斜め方向は除外
            if abs(dx) == abs(dy):
                continue
            var nx = x + dx
            var ny = y + dy
            # マップの範囲内かチェック
            if nx >= 0 and nx < width and ny >= 0 and ny < height:
                neighbors.append([nx, ny])
    return neighbors

static func connect_disconnected_components(cave: MapData, config_width: int, config_height: int) -> MapData:
    var visited = ArrayUtils.create_2d_array(config_width, config_height, false)
    var components: Array = []
    for y in range(1, config_height - 1):
        for x in range(1, config_width - 1):
            # まだ訪れていない床タイルから探索を開始
            if cave.get_tile_xy(x, y).terrain_type == Enum.TerrainTileType.FLOOR and not visited[x][y]:
                # 深さ優先探索で連結成分を収集
                var stack: Array = [Vector2i(x, y)]
                # 収集したタイルのリスト
                var component: Array = []
                # スタックが空になるまで探索
                while stack.size() > 0:
                    # スタックからタイルを取り出し
                    var cell = stack.pop_back()
                    # 既に訪れていればスキップ
                    if visited[cell.x][cell.y]:
                        continue
                    # まだ訪れていなければ訪問済みにマークし、連結成分に追加
                    visited[cell.x][cell.y] = true
                    component.append(cell)
                    # 隣接セルをチェックし、床タイルで未訪問のものをスタックに追加
                    var neighbors = get_neighbors(cell.x, cell.y, config_width, config_height)
                    for n in neighbors:
                        if cave.get_tile_xy(n[0], n[1]).terrain_type == Enum.TerrainTileType.FLOOR and not visited[n[0]][n[1]]:
                            stack.append(Vector2i(n[0], n[1]))
                components.append(component)

    # 連結成分が複数ある場合、それらを接続
    if components.size() > 1:
        var main_comp = components[0]
        for comp in components.slice(1, components.size()):
            # 各連結成分の代表点同士を最短で接続
            var min_dist = 1e9
            var best_a: Vector2i
            var best_b: Vector2i
            for a in main_comp:
                for b in comp:
                    var dist = a.distance_to(b)
                    if dist < min_dist:
                        min_dist = dist
                        best_a = a
                        best_b = b
            # 最短距離の2点間に通路を生成
            cave = RoomGenerator.carve_h_corridor(cave, best_a.x, best_b.x, best_a.y)
            cave = RoomGenerator.carve_v_corridor(cave, best_a.y, best_b.y, best_b.x)
            main_comp += comp

    return cave
