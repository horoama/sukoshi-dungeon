class_name DungeonGenerator
extends Node

var dungeon : Dungeon

func _ready() -> void:
    dungeon = get_parent() as Dungeon

# 洞窟を生成するメイン関数
func generate_cave(config: DungeonConfig, prev_map: MapData = null) -> MapData:
    # 部屋と通路の初期生成
    var level = 1
    if prev_map != null:
        level = prev_map.level + 1
    var cave : MapData = RoomGenerator.generate_rooms_and_corridors(
        MapData.new(config.map_width, config.map_height, level),
        config.room_attempts,
        config.room_min_size,
        config.room_max_size
    )
    
    # 内部領域のみランダムに地形を生成
    for y in range(1, config.map_height-1):
        for x in range(1, config.map_width-1):
            if randf() < config.wall_rate:
                cave.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.WALL)  # 一定確率で壁を配置
            else:
                cave.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.FLOOR)  # それ以外は床を配置

    # セルオートマトンによる地形の洗練化
    for step in range(config.simulation_steps):
        cave = CellularAutomata.do_simulation_step(cave)

    
    # 内部領域の総タイル数を計算
    var total = (config.map_width - 2) * (config.map_height - 2)
    # 内部の壁の位置を記録
    var wall_cells = []
    for y in range(1, config.map_height - 1):
        for x in range(1, config.map_width - 1):
            if cave.get_tile_xy(x, y).terrain_type == Enum.TerrainTileType.WALL:
                wall_cells.append(Vector2i(x, y))
    var wall_count = wall_cells.size()
    var max_wall = total * config.wall_rate

    # 壁が多すぎる場合、床を増やすのみのセル・オートマトンを実行
    if wall_count > max_wall:
        cave = CellularAutomata.do_simulation_step(cave, true , false)

    # 外周の壁を再設定
    for x in range(config.map_width):
        cave.get_tile_xy(x, 0).set_terrain_type(Enum.TerrainTileType.WALL)
        cave.get_tile_xy(x, config.map_height-1).set_terrain_type(Enum.TerrainTileType.WALL)
    for y in range(config.map_height):
        cave.get_tile_xy(0, y).set_terrain_type(Enum.TerrainTileType.WALL)
        cave.get_tile_xy(config.map_width-1, y).set_terrain_type(Enum.TerrainTileType.WALL)

    # prev_map がある場合はそのDOWN_STAIRSを探す
    # その座標と同じ場所にUP_STAIRSを配置
    if prev_map != null:
        for tile in prev_map.tiles:
            if tile.object_type == Enum.ObjectType.DOWN_STAIRS:
                # 階段を設置する
                cave.get_tile_xy(tile.position.x, tile.position.y).set_object_type(Enum.ObjectType.UP_STAIRS)
                cave.get_tile_xy(tile.position.x, tile.position.y).set_terrain_type(Enum.TerrainTileType.FLOOR)
                # 周りのタイルに床に変更(外周を除く)
                var neighbors = MapConnector.get_neighbors(tile.position.x, tile.position.y, config.map_width, config.map_height)
                for n in neighbors:
                    cave.get_tile_xy(n[0], n[1]).set_terrain_type(Enum.TerrainTileType.FLOOR)

    # 連結成分を検出し、分断されている場合は通路で接続
    cave = MapConnector.connect_disconnected_components(cave, config.map_width, config.map_height)
        
    return cave


# After generate map
## set stair tiles, etc.
## Return positions of stairs
func finalize_map(map_data: MapData) -> Array[Tile]:
    return ObjectPlacer.finalize_map(dungeon, map_data)
