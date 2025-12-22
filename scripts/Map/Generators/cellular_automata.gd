class_name CellularAutomata
extends RefCounted

static func count_walls_around(map: MapData, x: int, y: int) -> int:
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
                if map.get_tile_xy(nx, ny).terrain_type == Enum.TerrainTileType.WALL:
                    wall_count += 1
    return wall_count

static func do_simulation_step(map: MapData, target_floor: bool = true, target_wall: bool = true) -> MapData:
    var new_map_data : MapData = MapData.new(map.width, map.height, map.level)
    for y in range(map.height):
        for x in range(map.width):
            var wall_count = count_walls_around(map, x, y)
            # 現在のセルが壁の場合
            if map.get_tile_xy(x, y).terrain_type == Enum.TerrainTileType.WALL and target_wall:
                # 周囲の壁が4未満なら床に変更
                if wall_count < 4:
                    new_map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.FLOOR)
                elif target_wall:
                    new_map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.WALL)
            # 現在のセルが床の場合
            elif target_floor:
                # 周囲の壁が5以上なら壁に変更
                if wall_count >= 5:
                    new_map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.WALL)
                else:
                    new_map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.FLOOR)
    return new_map_data
