class_name DungeonGenerator
extends Node




func _ready() -> void:
    pass


# 指定された座標の周囲8方向の壁の数を数える関数
func count_walls_around(map: MapData, x: int, y: int) -> int:
    var wall_count: int = 0
    # 8方向の隣接セルをチェック
    for dy in [-1, 0, 1]:
        for dx in [-1, 0, 1]:
            if dx == 0 and dy == 0:
                continue
            var nx = x + dx
            var ny = y + dy
            # マップの範囲内かチェック
            if nx >= 0 and nx < map.width and ny >= 0 and ny < map.height:
                if map.get_tile_xy(nx, ny).terrain_type == "WALL":
                    wall_count += 1
    return wall_count

# セルオートマトンのシミュレーションを1ステップ実行する関数
func do_simulation_step(map: MapData, target_floor: bool = true, tartget_wall: bool = true) -> MapData:
    var new_map_data : MapData = MapData.new(map.width, map.height, map.level)
    for y in range(map.height):
        for x in range(map.width):
            var wall_count = count_walls_around(map, x, y)
            # 現在のセルが壁の場合
            if map.get_tile_xy(x, y).terrain_type == "WALL" and tartget_wall:
                # 周囲の壁が4未満なら床に変更
                if wall_count < 4:
                    #new_map_data[y].append(Tile.FLOOR)
                    new_map_data.change_terrain_tile_type(x, y, "FLOOR")
                elif tartget_wall:
                    new_map_data.change_terrain_tile_type(x, y, "WALL")
            # 現在のセルが床の場合
            elif floor:
                # 周囲の壁が5以上なら壁に変更
                if wall_count >= 5:
                    new_map_data.change_terrain_tile_type(x, y, "WALL")
                else:
                    new_map_data.change_terrain_tile_type(x, y, "FLOOR")
    return new_map_data

# 指定された位置に部屋を配置する関数
func place_room(map_data: MapData, room_x: int, room_y: int, room_width: int, room_height: int) -> void:
    for y in range(room_y, room_y + room_height):
        for x in range(room_x, room_x + room_width):
            # マップの範囲内かチェック
            if x >= 0 and x < map_data.width and y >= 0 and y < map_data.height:
                map_data.change_terrain_tile_type(x, y, "FLOOR")

# 水平方向の通路を作成する関数
func carve_h_corridor(map: MapData, x1: int, x2: int, y: int) -> MapData:
    for x in range(min(x1, x2), max(x1, x2) + 1):
        # マップの範囲内かチェック
        if x >= 0 and x < map.width and y >= 0 and y < map.height:
            map.change_terrain_tile_type(x, y, "FLOOR")
    return map

# 垂直方向の通路を作成する関数
func carve_v_corridor(map: MapData, y1: int, y2: int, x: int) -> MapData:
    for y in range(min(y1, y2), max(y1, y2) + 1):
        # マップの範囲内かチェック
        if x >= 0 and x < map.width and y >= 0 and y < map.height:
            map.change_terrain_tile_type(x, y, "FLOOR")
    return map

# 部屋と通路を生成する関数
# rooom_count: 生成する部屋の数
# room_min_size: 部屋の最小サイズ
# room_max_size: 部屋の最大サイズ
func generate_rooms_and_corridors(map_data: MapData, room_count: int, room_min_size: int, room_max_size: int) -> MapData:
    # マップを壁で初期化
    var rooms: Array = []
    for i in range(room_count):
        # ランダムなサイズの部屋を生成
        var room_width = randi() % (room_max_size - room_min_size + 1) + room_min_size
        var room_height = randi() % (room_max_size - room_min_size + 1) + room_min_size
        # ランダムな位置に部屋を配置
        var room_x = randi_range(1, map_data.width - room_width)
        var room_y = randi_range(1, map_data.height - room_height)
        var new_room = [room_x, room_y, room_width, room_height]
        var overlaps = false
        # 他の部屋と重なっていないかチェック
        for other_room in rooms:
            var ox = other_room[0]
            var oy = other_room[1]
            var ow = other_room[2]
            var oh = other_room[3]
            if (room_x < ox + ow and room_x + room_width > ox and
                room_y < oy + oh and room_y + room_height > oy):
                overlaps = true
                break
        # 重なっていなければ部屋を配置し、前の部屋と通路で接続
        if not overlaps:
            place_room(map_data, room_x, room_y, room_width, room_height)
            if rooms.size() > 0:
                var prev_room = rooms[rooms.size() - 1]
                var prev_cx = prev_room[0] + prev_room[2] / 2
                var prev_cy = prev_room[1] + prev_room[3] / 2
                @warning_ignore("integer_division")
                var cur_cx = room_x + room_width / 2
                @warning_ignore("integer_division")
                var cur_cy = room_y + room_height / 2
                # ランダムに水平・垂直の通路を生成
                if randi() % 2 == 0:
                    map_data = carve_h_corridor(map_data, prev_cx, cur_cx, prev_cy)
                    map_data = carve_v_corridor(map_data, prev_cy, cur_cy, cur_cx)
                else:
                    map_data = carve_v_corridor(map_data, prev_cy, cur_cy, prev_cx)
                    map_data = carve_h_corridor(map_data, prev_cx, cur_cx, cur_cy)
            rooms.append(new_room)
    return map_data

# 指定された座標の隣接セル（縦横方向）を取得する関数
func get_neighbors(x: int, y: int, width: int, height: int) -> Array:
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

# 洞窟を生成するメイン関数
func generate_cave(config: DungeonConfig, prev_map: MapData = null) -> MapData:
    # 部屋と通路の初期生成
    var level = 1
    if prev_map != null:
        level = prev_map.level + 1
    var cave : MapData = generate_rooms_and_corridors(
        MapData.new(config.map_width, config.map_height, level),
        config.room_attempts,
        config.room_min_size,
        config.room_max_size
    )
    
    # 内部領域のみランダムに地形を生成
    for y in range(1, config.map_height-1):
        for x in range(1, config.map_width-1):
            if randf() < config.wall_rate:
                cave.change_terrain_tile_type(x, y, "WALL")  # 一定確率で壁を配置
            else:
                cave.change_terrain_tile_type(x, y, "FLOOR")  # それ以外は床を配置

    # セルオートマトンによる地形の洗練化
    for step in range(config.simulation_steps):
        cave = do_simulation_step(cave)

    
    # 内部領域の総タイル数を計算
    var total = (config.map_width - 2) * (config.map_height - 2)
    # 内部の壁の位置を記録
    var wall_cells = []
    for y in range(1, config.map_height - 1):
        for x in range(1, config.map_width - 1):
            if cave.get_tile_xy(x, y).terrain_type == "WALL":
                wall_cells.append(Vector2i(x, y))
    var wall_count = wall_cells.size()
    var max_wall = total * config.wall_rate

    # 壁が多すぎる場合、床を増やすのみのセル・オートマトンを実行
    if wall_count > max_wall:
        cave = do_simulation_step(cave, true , false)

    # 外周の壁を再設定
    for x in range(config.map_width):
        cave.change_terrain_tile_type(x, 0, "WALL")
        cave.change_terrain_tile_type(x, config.map_height-1, "WALL")
    for y in range(config.map_height):
        cave.change_terrain_tile_type(0, y, "WALL")
        cave.change_terrain_tile_type(config.map_width-1, y, "WALL")

    # prev_map がある場合はそのDOWN_STAIRSを探す
    # その座標と同じ場所にUP_STAIRSを配置
    if prev_map != null:
        for tile in prev_map.tiles:
            if tile.object_type == "DOWN_STAIRS":
                # 階段を設置する
                cave.change_object_tile_type(tile.position.x, tile.position.y, "UP_STAIRS")
                cave.change_terrain_tile_type(tile.position.x, tile.position.y, "FLOOR")
                # 周りのタイルに床に変更(外周を除く)
                var neighbors = get_neighbors(tile.position.x, tile.position.y, config.map_width, config.map_height)
                for n in neighbors:
                    cave.change_terrain_tile_type(n[0], n[1], "FLOOR")
            
    # 連結成分を検出し、分断されている場合は通路で接続
    var visited = ArrayUtils.create_2d_array(config.map_width, config.map_height, false)
    var components: Array = []
    for y in range(1, config.map_height - 1):
        for x in range(1, config.map_width - 1):
            # まだ訪れていない床タイルから探索を開始
            if cave.get_tile_xy(x, y).terrain_type == "FLOOR" and not visited[x][y]:
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
                    var neighbors = get_neighbors(cell.x, cell.y, config.map_width, config.map_height)
                    for n in neighbors:
                        if cave.get_tile_xy(n[0], n[1]).terrain_type == "FLOOR" and not visited[n[0]][n[1]]:
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
            cave = carve_h_corridor(cave, best_a.x, best_b.x, best_a.y)
            cave = carve_v_corridor(cave, best_a.y, best_b.y, best_b.x)
            main_comp += comp
        
    return cave


# After generate map
## set stair tiles, etc.
## Return positions of stairs
func finalize_map(map_data: MapData) -> Array[Tile]:
    # ここに最終的なマップ調整のコードを追加
    return set_next_stairs(map_data, 1)

func set_next_stairs(map_data: MapData, number: int) -> Array[Tile]:
    # 階段を設置するコードを追加
    var empty_tiles: Array[Tile] = []
    var stair_tiles: Array[Tile] = []
    var up_stairs: Array[Tile] = map_data.filter_tiles(func(tile: Tile) -> bool:
        return tile.object_type == "UP_STAIRS"
    )
    for tile in map_data.tiles:
        if tile.terrain_type == "FLOOR" or tile.object_type == "UP_STAIRS":
            # UP_STARISから10タイル以内のタイルは除外
            var distance_ok = true
            for up_stair in up_stairs:
                if up_stair.position.distance_to(tile.position) <= 20:
                    distance_ok =false
                    break
            if distance_ok:
                empty_tiles.append(tile)
    
    empty_tiles.shuffle()
    for i in range(min(number, empty_tiles.size())):
        var tile = empty_tiles[i]
        tile.set_object_type("DOWN_STAIRS")
        stair_tiles.append(tile)
    return stair_tiles
