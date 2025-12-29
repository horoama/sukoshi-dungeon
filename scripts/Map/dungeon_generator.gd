class_name DungeonGenerator
extends Node

var dungeon : Dungeon

func _ready() -> void:
    dungeon = get_parent() as Dungeon

# 洞窟ダンジョンを生成するメインパイプライン
#
# 以下の手順でダンジョンを生成します：
# 1. 部屋と通路の基本構造を作成
# 2. ランダムなノイズ（壁）を追加
# 3. セルオートマトンで地形をスムーズ化
# 4. 壁の割合を調整
# 5. 外周を壁で囲む
# 6. 階段（上り/下り）の配置
# 7. 分断された領域（連結成分）の接続
#
# @param config: ダンジョン生成の設定（サイズ、部屋数、シミュレーション回数など）
# @param prev_map: 前の階層のマップデータ（階段の接続位置決定に使用）。省略時は新規生成。
# @return: 完成したマップデータ
func generate_cave(config: DungeonConfig, prev_map: MapData = null) -> MapData:
    var map_data = _initialize_with_rooms(config, prev_map)
    _apply_random_noise(map_data, config)
    _simulate_cellular_automata(map_data, config)
    _adjust_wall_ratio(map_data, config)
    _build_outer_walls(map_data)
    if prev_map != null:
        _setup_stairs_from_previous(map_data, prev_map, config)
    _ensure_connectivity(map_data, config)
    return map_data

# マップ生成後の最終処理を行う関数
#
# アイテムの配置や次の階への階段（DOWN_STAIRS）の配置を行います。
#
# @param map_data: 生成されたマップデータ
# @return: 配置された階段タイルの配列
func finalize_map(map_data: MapData) -> Array[Tile]:
    _place_initial_items(map_data)
    return _place_down_stairs(map_data, 1)

# --- Private / Helper Methods ---

# 部屋と通路で初期化されたマップを作成する
func _initialize_with_rooms(config: DungeonConfig, prev_map: MapData) -> MapData:
    var level = 1
    if prev_map != null:
        level = prev_map.level + 1

    var map_data = MapData.new(config.map_width, config.map_height, level)
    return generate_rooms_and_corridors(
        map_data,
        config.room_attempts,
        config.room_min_size,
        config.room_max_size
    )

# 内部領域にランダムな壁ノイズを適用する
func _apply_random_noise(map_data: MapData, config: DungeonConfig) -> void:
    for y in range(1, config.map_height - 1):
        for x in range(1, config.map_width - 1):
            if randf() < config.wall_rate:
                map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.WALL)
            else:
                map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.FLOOR)

# MapDataの内容（Tiles配列）を更新するヘルパー関数
func _copy_map_data_content(target: MapData, source: MapData) -> void:
    target.tiles = source.tiles
    # width, height, level are assumed to be consistent

# セルオートマトンによる地形の洗練化を実行する
func _simulate_cellular_automata(map_data: MapData, config: DungeonConfig) -> void:
    var current_map = map_data
    for step in range(config.simulation_steps):
        current_map = do_simulation_step(current_map)

    # 最終的な結果を元のMapDataに反映
    _copy_map_data_content(map_data, current_map)

# 壁の割合を調整する
func _adjust_wall_ratio(map_data: MapData, config: DungeonConfig) -> void:
    var total = (config.map_width - 2) * (config.map_height - 2)
    var wall_count = 0
    for y in range(1, config.map_height - 1):
        for x in range(1, config.map_width - 1):
            if map_data.get_tile_xy(x, y).terrain_type == Enum.TerrainTileType.WALL:
                wall_count += 1

    var max_wall = total * config.wall_rate
    if wall_count > max_wall:
        var new_map = do_simulation_step(map_data, true, false)
        _copy_map_data_content(map_data, new_map)

# 外周を壁にする
func _build_outer_walls(map_data: MapData) -> void:
    for x in range(map_data.width):
        map_data.get_tile_xy(x, 0).set_terrain_type(Enum.TerrainTileType.WALL)
        map_data.get_tile_xy(x, map_data.height - 1).set_terrain_type(Enum.TerrainTileType.WALL)
    for y in range(map_data.height):
        map_data.get_tile_xy(0, y).set_terrain_type(Enum.TerrainTileType.WALL)
        map_data.get_tile_xy(map_data.width - 1, y).set_terrain_type(Enum.TerrainTileType.WALL)

# 前の階層の階段位置に合わせて上り階段を設置する
func _setup_stairs_from_previous(map_data: MapData, prev_map: MapData, config: DungeonConfig) -> void:
    for tile in prev_map.tiles:
        if tile.object_type == Enum.ObjectType.DOWN_STAIRS:
            map_data.get_tile_xy(tile.position.x, tile.position.y).set_object_type(Enum.ObjectType.UP_STAIRS)
            map_data.get_tile_xy(tile.position.x, tile.position.y).set_terrain_type(Enum.TerrainTileType.FLOOR)
            var neighbors = get_neighbors(tile.position.x, tile.position.y, config.map_width, config.map_height)
            for n in neighbors:
                map_data.get_tile_xy(n[0], n[1]).set_terrain_type(Enum.TerrainTileType.FLOOR)

# 連結成分を接続する
func _ensure_connectivity(map_data: MapData, config: DungeonConfig) -> void:
    var visited = ArrayUtils.create_2d_array(config.map_width, config.map_height, false)
    var components: Array = []

    # 連結成分の検出
    for y in range(1, config.map_height - 1):
        for x in range(1, config.map_width - 1):
            if map_data.get_tile_xy(x, y).terrain_type == Enum.TerrainTileType.FLOOR and not visited[x][y]:
                var component = _collect_connected_component(map_data, x, y, visited, config)
                components.append(component)

    # 連結成分の接続
    if components.size() > 1:
        var main_comp = components[0]
        for i in range(1, components.size()):
            var comp = components[i]
            _connect_components(map_data, main_comp, comp)
            main_comp += comp

# 連結成分を探索収集する (BFS/DFS)
func _collect_connected_component(map_data: MapData, start_x: int, start_y: int, visited: Array, config: DungeonConfig) -> Array:
    var stack: Array = [Vector2i(start_x, start_y)]
    var component: Array = []
    while stack.size() > 0:
        var cell = stack.pop_back()
        if visited[cell.x][cell.y]:
            continue
        visited[cell.x][cell.y] = true
        component.append(cell)

        var neighbors = get_neighbors(cell.x, cell.y, config.map_width, config.map_height)
        for n in neighbors:
            if map_data.get_tile_xy(n[0], n[1]).terrain_type == Enum.TerrainTileType.FLOOR and not visited[n[0]][n[1]]:
                stack.append(Vector2i(n[0], n[1]))
    return component

# 2つの連結成分を最短距離で接続する
func _connect_components(map_data: MapData, comp_a: Array, comp_b: Array) -> void:
    var min_dist = 1e9
    var best_a: Vector2i
    var best_b: Vector2i

    # 最も近い2点を探す（総当たり）
    for a in comp_a:
        for b in comp_b:
            var dist = a.distance_to(b)
            if dist < min_dist:
                min_dist = dist
                best_a = a
                best_b = b

    # 通路で接続
    carve_h_corridor(map_data, best_a.x, best_b.x, best_a.y)
    carve_v_corridor(map_data, best_a.y, best_b.y, best_b.x)

# --- Original Methods (Preserved / Adjusted) ---

func count_walls_around(map: MapData, x: int, y: int) -> int:
    var wall_count: int = 0
    for dy in [-1, 0, 1]:
        for dx in [-1, 0, 1]:
            if dx == 0 and dy == 0:
                continue
            var nx = x + dx
            var ny = y + dy
            if nx >= 0 and nx < map.width and ny >= 0 and ny < map.height:
                if map.get_tile_xy(nx, ny).terrain_type == Enum.TerrainTileType.WALL:
                    wall_count += 1
    return wall_count

func do_simulation_step(map: MapData, target_floor: bool = true, target_wall: bool = true) -> MapData:
    var new_map_data : MapData = MapData.new(map.width, map.height, map.level)
    for y in range(map.height):
        for x in range(map.width):
            var wall_count = count_walls_around(map, x, y)
            if map.get_tile_xy(x, y).terrain_type == Enum.TerrainTileType.WALL and target_wall:
                if wall_count < 4:
                    new_map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.FLOOR)
                elif target_wall:
                    new_map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.WALL)
            elif target_floor:
                if wall_count >= 5:
                    new_map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.WALL)
                else:
                    new_map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.FLOOR)
    return new_map_data

func place_room(map_data: MapData, room_x: int, room_y: int, room_width: int, room_height: int) -> void:
    for y in range(room_y, room_y + room_height):
        for x in range(room_x, room_x + room_width):
            if x >= 0 and x < map_data.width and y >= 0 and y < map_data.height:
                map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.FLOOR)

func carve_h_corridor(map: MapData, x1: int, x2: int, y: int) -> MapData:
    for x in range(min(x1, x2), max(x1, x2) + 1):
        if x >= 0 and x < map.width and y >= 0 and y < map.height:
            map.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.FLOOR)
    return map

func carve_v_corridor(map: MapData, y1: int, y2: int, x: int) -> MapData:
    for y in range(min(y1, y2), max(y1, y2) + 1):
        if x >= 0 and x < map.width and y >= 0 and y < map.height:
            map.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.FLOOR)
    return map

func generate_rooms_and_corridors(map_data: MapData, room_count: int, room_min_size: int, room_max_size: int) -> MapData:
    var rooms: Array = []
    for i in range(room_count):
        var room_width = randi() % (room_max_size - room_min_size + 1) + room_min_size
        var room_height = randi() % (room_max_size - room_min_size + 1) + room_min_size
        var room_x = randi_range(1, map_data.width - room_width)
        var room_y = randi_range(1, map_data.height - room_height)
        var new_room = [room_x, room_y, room_width, room_height]

        if _is_overlapping(new_room, rooms):
            continue

        place_room(map_data, room_x, room_y, room_width, room_height)

        if rooms.size() > 0:
            var prev_room = rooms[rooms.size() - 1]
            _connect_rooms(map_data, prev_room, new_room)

        rooms.append(new_room)
    return map_data

func _is_overlapping(new_room: Array, rooms: Array) -> bool:
    var x = new_room[0]
    var y = new_room[1]
    var w = new_room[2]
    var h = new_room[3]

    for other in rooms:
        var ox = other[0]
        var oy = other[1]
        var ow = other[2]
        var oh = other[3]
        if (x < ox + ow and x + w > ox and y < oy + oh and y + h > oy):
            return true
    return false

func _connect_rooms(map_data: MapData, room_a: Array, room_b: Array) -> void:
    var ax = room_a[0] + room_a[2] / 2
    var ay = room_a[1] + room_a[3] / 2
    var bx = room_b[0] + room_b[2] / 2
    var by = room_b[1] + room_b[3] / 2

    if randi() % 2 == 0:
        carve_h_corridor(map_data, ax, bx, ay)
        carve_v_corridor(map_data, ay, by, bx)
    else:
        carve_v_corridor(map_data, ay, by, ax)
        carve_h_corridor(map_data, ax, bx, by)

func get_neighbors(x: int, y: int, width: int, height: int) -> Array:
    var neighbors: Array = []
    for dy in [-1, 0, 1]:
        for dx in [-1, 0, 1]:
            if abs(dx) == abs(dy):
                continue
            var nx = x + dx
            var ny = y + dy
            if nx >= 0 and nx < width and ny >= 0 and ny < height:
                neighbors.append([nx, ny])
    return neighbors

func _place_initial_items(map_data: MapData) -> void:
    var emptys = map_data.filter_tiles(func(tile: Tile) -> bool:
        return tile.terrain_type == Enum.TerrainTileType.FLOOR and tile.object_type == Enum.ObjectType.NONE
    )
    if emptys.is_empty():
        return

    emptys.shuffle()
    var selected = emptys[0]
    var item = Entity.new(map_data, selected.position, "rice_ball")
    if dungeon:
        dungeon.add_entity_to_map(map_data, selected.position, item)

func _place_down_stairs(map_data: MapData, number: int) -> Array[Tile]:
    var empty_tiles: Array[Tile] = []
    var stair_tiles: Array[Tile] = []

    var up_stairs: Array[Tile] = map_data.filter_tiles(func(tile: Tile) -> bool:
        return tile.object_type == Enum.ObjectType.UP_STAIRS
    )

    for tile in map_data.tiles:
        if tile.terrain_type == Enum.TerrainTileType.FLOOR or tile.object_type == Enum.ObjectType.UP_STAIRS:
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
        tile.set_object_type(Enum.ObjectType.DOWN_STAIRS)
        tile.set_terrain_type(Enum.TerrainTileType.FLOOR)
        stair_tiles.append(tile)
    return stair_tiles
