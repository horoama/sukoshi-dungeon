class_name RoomGenerator
extends RefCounted

static func place_room(map_data: MapData, room_x: int, room_y: int, room_width: int, room_height: int) -> void:
    for y in range(room_y, room_y + room_height):
        for x in range(room_x, room_x + room_width):
            # マップの範囲内かチェック
            if x >= 0 and x < map_data.width and y >= 0 and y < map_data.height:
                map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.FLOOR)

static func carve_h_corridor(map: MapData, x1: int, x2: int, y: int) -> MapData:
    for x in range(min(x1, x2), max(x1, x2) + 1):
        # マップの範囲内かチェック
        if x >= 0 and x < map.width and y >= 0 and y < map.height:
            map.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.FLOOR)
    return map

static func carve_v_corridor(map: MapData, y1: int, y2: int, x: int) -> MapData:
    for y in range(min(y1, y2), max(y1, y2) + 1):
        # マップの範囲内かチェック
        if x >= 0 and x < map.width and y >= 0 and y < map.height:
            map.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.FLOOR)
    return map

static func generate_rooms_and_corridors(map_data: MapData, room_count: int, room_min_size: int, room_max_size: int) -> MapData:
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
