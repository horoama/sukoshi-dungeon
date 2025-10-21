extends Node

@export var tile_map: TileMapLayer
@export var map_width: int = 24
@export var map_height: int = 19

# store generated data and tile lists as plain Arrays to avoid nested typed collections
var tile_map_data: Array = []
var tileset_dict: Dictionary = {
    "FLOOR": Vector2i(0, 0),
    "WALL": Vector2i(0, 1),
}

func _ready() -> void:
    var wall_rate = 0.45
    var simulation_steps = 5
    var room_attempts = 3
    var room_min_size = 3
    var room_max_size = 6
    init_grid()
    tile_map_data = generate_cave(
        map_width,
        map_height,
        wall_rate,
        simulation_steps,
        room_attempts,
        room_min_size,
        room_max_size
    )
    update_tile_map()

func init_grid():
    # WALLで初期化
    tile_map_data = ArrayUtils.create_2d_array(map_width, map_height, tileset_dict["WALL"])

func update_tile_map() -> void:
    for y in range(tile_map_data.size()):
        for x in range(tile_map_data[y].size()):
            var tile_type = tile_map_data[y][x]
            tile_map.set_cell(Vector2i(x, y), 0, tile_type)

# Generate dungeon map
func generate_dungeon(width: int, height: int, wall_rate: float) -> Array:
    var map_data: Array = []
    for y in range(height):
        map_data.append([])
        for x in range(width):
            if randf() < wall_rate:
                map_data[y].append(tileset_dict["WALL"])
            else:
                map_data[y].append(tileset_dict["FLOOR"])
    return map_data

func count_walls_around(map_data: Array, x: int, y: int) -> int:
    var wall_count: int = 0
    # count walls in 8 directions
    for dy in [-1, 0, 1]:
        for dx in [-1, 0, 1]:
            if dx == 0 and dy == 0:
                continue
            var nx = x + dx
            var ny = y + dy
            if nx >= 0 and nx < map_data[0].size() and ny >= 0 and ny < map_data.size():
                 if map_data[ny][nx] == tileset_dict["WALL"]:
                      wall_count += 1
    return wall_count
func do_simulation_step(map_data: Array) -> Array:
    var new_map_data: Array = []
    for y in range(map_data.size()):
        new_map_data.append([])
        for x in range(map_data[y].size()):
            var wall_count = count_walls_around(map_data, x, y)
            if map_data[y][x] == tileset_dict["WALL"]:
                if wall_count < 4:
                    new_map_data[y].append(tileset_dict["FLOOR"])
                else:
                    new_map_data[y].append(tileset_dict["WALL"])
            else:
                if wall_count >= 5:
                    new_map_data[y].append(tileset_dict["WALL"])
                else:
                    new_map_data[y].append(tileset_dict["FLOOR"])
    return new_map_data

func place_room(map_data: Array, room_x: int, room_y: int, room_width: int, room_height: int) -> void:
    for y in range(room_y, room_y + room_height):
        for x in range(room_x, room_x + room_width):
            if x >= 0 and x < map_data[0].size() and y >= 0 and y < map_data.size():
                map_data[y][x] = tileset_dict["FLOOR"]

func carve_h_corridor(map_data: Array, x1: int, x2: int, y: int) -> void:
    for x in range(min(x1, x2), max(x1, x2) + 1):
        if x >= 0 and x < map_data[0].size() and y >= 0 and y < map_data.size():
            map_data[y][x] = tileset_dict["FLOOR"]

func carve_v_corridor(map_data: Array, y1: int, y2: int, x: int) -> void:
    for y in range(min(y1, y2), max(y1, y2) + 1):
        if x >= 0 and x < map_data[0].size() and y >= 0 and y < map_data.size():
            map_data[y][x] = tileset_dict["FLOOR"]

func generate_rooms_and_corridors(map_data: Array, room_count: int, room_min_size: int, room_max_size: int) -> Array:
    map_data = ArrayUtils.create_2d_array(map_width, map_height, tileset_dict["WALL"])
    var rooms: Array = []
    for i in range(room_count):
        var room_width = randi() % (room_max_size - room_min_size + 1) + room_min_size
        var room_height = randi() % (room_max_size - room_min_size + 1) + room_min_size
        var room_x = randi_range(1, map_data[0].size() - room_width)
        var room_y = randi_range(1, map_data.size() - room_height)
        var new_room = [room_x, room_y, room_width, room_height]
        var overlaps = false
        for other_room in rooms:
            var ox = other_room[0]
            var oy = other_room[1]
            var ow = other_room[2]
            var oh = other_room[3]
            if (room_x < ox + ow and room_x + room_width > ox and
                room_y < oy + oh and room_y + room_height > oy):
                overlaps = true
                break
        if not overlaps:
            place_room(map_data, room_x, room_y, room_width, room_height)
            if rooms.size() > 0:
                var prev_room = rooms[rooms.size() - 1]
                var prev_cx = prev_room[0] + prev_room[2] / 2
                var prev_cy = prev_room[1] + prev_room[3] / 2
                var cur_cx = room_x + room_width / 2
                var cur_cy = room_y + room_height / 2
                if randi() % 2 == 0:
                    carve_h_corridor(map_data, prev_cx, cur_cx, prev_cy)
                    carve_v_corridor(map_data, prev_cy, cur_cy, cur_cx)
                else:
                    carve_v_corridor(map_data, prev_cy, cur_cy, prev_cx)
                    carve_h_corridor(map_data, prev_cx, cur_cx, cur_cy)
            rooms.append(new_room)
    return map_data


func generate_cave(
    width: int,
    height: int,
    wall_rate: float,
    simulation_steps: int,
    room_attempts: int,
    room_min_size: int,
    room_max_size: int,
    ) -> Array:
    var map_data: Array = []
    # Initial random fill
    var cave = generate_rooms_and_corridors(
        map_data,
        room_attempts,
        room_min_size,
        room_max_size
    )
    for y in range(height-1):
        for x in range(width-1):
            if randf() < wall_rate:
                cave[y][x] = tileset_dict["WALL"]
            else:
                cave[y][x] = tileset_dict["FLOOR"]
    for step in range(simulation_steps):
        cave = do_simulation_step(cave)
    var total = (width - 2) * (height - 2)
    # count wall cells
    var wall_cells = []
    for y in range(1, height - 1):
        for x in range(1, width - 1):
            if cave[y][x] == tileset_dict["WALL"]:
                wall_cells.append(Vector2i(x, y))
    var wall_count = wall_cells.size()
    var max_wall = total * wall_rate
    if wall_count > max_wall:
        # random room placement
        var to_remove = wall_count - max_wall
        while to_remove > 0:
            var index = randi() % wall_cells.size()
            var cell = wall_cells[index]
            map_data[cell.y][cell.x] = tileset_dict["FLOOR"]
            wall_cells.remove_at(index)
            to_remove -= 1
    # すべての部屋を通路で接続
    # 外周をWALLで囲む
    for x in range(width):
        cave[0][x] = tileset_dict["WALL"]
        cave[height - 1][x] = tileset_dict["WALL"]
    for y in range(height):
        cave[y][0] = tileset_dict["WALL"]
        cave[y][width - 1] = tileset_dict["WALL"]
    return cave
    
