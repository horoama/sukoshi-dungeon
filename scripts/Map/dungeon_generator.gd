class_name DungeonGenerator
extends Node

var dungeon : Dungeon

func _ready() -> void:
	dungeon = get_parent() as Dungeon

# 指定された座標の周囲8方向の壁の数を数える関数
#
# この関数はセルオートマトンの計算などで使用され、
# 対象のセルの周囲（ムーア近傍）にどれだけ壁が存在するかを返します。
#
# @param map: 判定対象のマップデータ
# @param x: 判定するセルのX座標
# @param y: 判定するセルのY座標
# @return: 周囲8方向にある壁タイルの数
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
				if map.get_tile_xy(nx, ny).terrain_type == Enum.TerrainTileType.WALL:
					wall_count += 1
	return wall_count

# セルオートマトンのシミュレーションを1ステップ実行する関数
#
# DungeonConfigの設定値を用いて、洞窟のような有機的な形状を生成・整地します。
# 壁が周囲に少なければ床になり、多ければ壁になるというルールを適用します。
#
# @param map: シミュレーションを行う元のマップデータ
# @param config: ダンジョン生成設定
# @param target_floor: 元が「床」のセルに対してルールを適用するかどうか
# @param target_wall: 元が「壁」のセルに対してルールを適用するかどうか
# @return: 1ステップ更新された新しいマップデータ
func _do_simulation_step(map: MapData, config: DungeonConfig, target_floor: bool = true, target_wall: bool = true) -> MapData:
	var new_map_data : MapData = MapData.new(map.width, map.height, map.level)
	for y in range(map.height):
		for x in range(map.width):
			var wall_count = count_walls_around(map, x, y)
			# 現在のセルが壁の場合
			if map.get_tile_xy(x, y).terrain_type == Enum.TerrainTileType.WALL and target_wall:
				# 周囲の壁が生存閾値未満なら床に変更
				if wall_count < config.survival_limit:
					new_map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.FLOOR)
				elif target_wall:
					new_map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.WALL)
			# 現在のセルが床の場合
			elif target_floor:
				# 周囲の壁が誕生閾値以上なら壁に変更
				if wall_count >= config.birth_limit:
					new_map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.WALL)
				else:
					new_map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.FLOOR)
	return new_map_data

# 洞窟ダンジョンを生成するメインパイプライン
#
# 以下の手順でダンジョンを生成します：
# 1. ランダムなノイズ（壁）で初期化
# 2. セルオートマトンで地形をスムーズ化
# 3. 外周を壁で囲む
# 4. 階段（上り/下り）の接続
# 5. 分断された領域（連結成分）の接続
#
# @param config: ダンジョン生成の設定（サイズ、部屋数、シミュレーション回数など）
# @param prev_map: 前の階層のマップデータ（階段の接続位置決定に使用）。省略時は新規生成。
# @return: 完成したマップデータ
func generate_cave(config: DungeonConfig, prev_map: MapData = null) -> MapData:
	var level = 1
	if prev_map != null:
		level = prev_map.level + 1

	# マップデータの生成（初期状態は壁）
	var map_data = MapData.new(config.map_width, config.map_height, level)

	# ランダムなノイズを適用
	_apply_noise(map_data, config)

	# セルオートマトンによる地形の洗練化
	for step in range(config.simulation_steps):
		map_data = _do_simulation_step(map_data, config)

	# 壁の量を調整（多すぎる場合は減らす）
	map_data = _adjust_wall_amount(map_data, config)

	# 外周を壁で囲む
	_apply_boundary_walls(map_data)

	# 前の階層からの階段接続
	if prev_map != null:
		_connect_stairs_from_previous(map_data, prev_map, config)

	# 連結成分の接続
	_ensure_connectivity(map_data)

	return map_data

# ランダムなノイズをマップに適用する関数
func _apply_noise(map_data: MapData, config: DungeonConfig) -> void:
	for y in range(1, config.map_height - 1):
		for x in range(1, config.map_width - 1):
			if randf() < config.wall_rate:
				map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.WALL)
			else:
				map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.FLOOR)

# 壁の総数を確認し、多すぎる場合は調整する関数
func _adjust_wall_amount(map_data: MapData, config: DungeonConfig) -> MapData:
	var total = (config.map_width - 2) * (config.map_height - 2)
	var wall_count = 0
	for y in range(1, config.map_height - 1):
		for x in range(1, config.map_width - 1):
			if map_data.get_tile_xy(x, y).terrain_type == Enum.TerrainTileType.WALL:
				wall_count += 1

	var max_wall = total * config.wall_rate
	if wall_count > max_wall:
		# 壁のみを対象に、生存チェックだけ行う（床を増やす）
		return _do_simulation_step(map_data, config, true, false)
	return map_data

# マップの外周を壁にする関数
func _apply_boundary_walls(map_data: MapData) -> void:
	var width = map_data.width
	var height = map_data.height
	for x in range(width):
		map_data.get_tile_xy(x, 0).set_terrain_type(Enum.TerrainTileType.WALL)
		map_data.get_tile_xy(x, height - 1).set_terrain_type(Enum.TerrainTileType.WALL)
	for y in range(height):
		map_data.get_tile_xy(0, y).set_terrain_type(Enum.TerrainTileType.WALL)
		map_data.get_tile_xy(width - 1, y).set_terrain_type(Enum.TerrainTileType.WALL)

# 前の階層の下り階段に対応する上り階段を配置する関数
func _connect_stairs_from_previous(map_data: MapData, prev_map: MapData, config: DungeonConfig) -> void:
	for tile in prev_map.tiles:
		if tile.object_type == Enum.ObjectType.DOWN_STAIRS:
			var x = tile.position.x
			var y = tile.position.y
			# 階段を設置
			map_data.get_tile_xy(x, y).set_object_type(Enum.ObjectType.UP_STAIRS)
			map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.FLOOR)
			# 周囲を床にする
			var neighbors = get_neighbors(x, y, map_data.width, map_data.height)
			for n in neighbors:
				map_data.get_tile_xy(n[0], n[1]).set_terrain_type(Enum.TerrainTileType.FLOOR)

# マップ内の分断された領域（連結成分）を検出し、全て接続する関数
func _ensure_connectivity(map_data: MapData) -> void:
	var components = _find_connected_components(map_data)
	if components.size() > 1:
		_connect_components(map_data, components)

# 連結成分（床の領域）を見つける関数
func _find_connected_components(map_data: MapData) -> Array:
	var visited = ArrayUtils.create_2d_array(map_data.width, map_data.height, false)
	var components: Array = []

	for y in range(1, map_data.height - 1):
		for x in range(1, map_data.width - 1):
			if map_data.get_tile_xy(x, y).terrain_type == Enum.TerrainTileType.FLOOR and not visited[x][y]:
				var component = []
				var stack = [Vector2i(x, y)]
				while stack.size() > 0:
					var cell = stack.pop_back()
					if visited[cell.x][cell.y]:
						continue
					visited[cell.x][cell.y] = true
					component.append(cell)

					var neighbors = get_neighbors(cell.x, cell.y, map_data.width, map_data.height)
					for n in neighbors:
						if map_data.get_tile_xy(n[0], n[1]).terrain_type == Enum.TerrainTileType.FLOOR and not visited[n[0]][n[1]]:
							stack.append(Vector2i(n[0], n[1]))
				components.append(component)
	return components

# 複数の連結成分を接続する関数
func _connect_components(map_data: MapData, components: Array) -> void:
	var main_comp = components[0]
	for i in range(1, components.size()):
		var comp = components[i]
		var min_dist = 1e9
		var best_a: Vector2i
		var best_b: Vector2i

		# 最も近い点を探す
		for a in main_comp:
			for b in comp:
				var dist = a.distance_to(b)
				if dist < min_dist:
					min_dist = dist
					best_a = a
					best_b = b

		# 通路で接続
		carve_h_corridor(map_data, best_a.x, best_b.x, best_a.y)
		carve_v_corridor(map_data, best_a.y, best_b.y, best_b.x)

		main_comp.append_array(comp)

# マップ生成後の最終処理を行う関数
#
# アイテムの配置や次の階への階段（DOWN_STAIRS）の配置を行います。
#
# @param map_data: 生成されたマップデータ
# @return: 配置された階段タイルの配列
func finalize_map(map_data: MapData) -> Array[Tile]:
	# アイテム配置の実行（TODO: コンフィグから数を取得するなど拡張可能に）
	_place_initial_items(map_data)
	# 下り階段の配置
	return _place_stairs(map_data, 1)

# アイテムをマップ上に配置する内部関数
func _place_initial_items(map_data: MapData) -> void:
	# 床かつオブジェクトが無い場所を探す
	var emptys = map_data.filter_tiles(func(tile: Tile) -> bool:
		return tile.terrain_type == Enum.TerrainTileType.FLOOR and tile.object_type == Enum.ObjectType.NONE
	)
	if emptys.is_empty():
		return

	emptys.shuffle()
	var selected = emptys[0]
	# TODO: アイテムの種類をランダム化、または定義ファイルから取得
	var item = Entity.new(map_data, selected.position, "rice_ball")
	dungeon.add_entity_to_map(map_data, selected.position, item)

# 次の階への階段を設置する関数
#
# 上り階段（UP_STAIRS）から一定距離離れた場所に下り階段を配置します。
#
# @param map_data: マップデータ
# @param number: 設置する階段の数
# @return: 設置された階段タイルの配列
func _place_stairs(map_data: MapData, number: int) -> Array[Tile]:
	var stair_tiles: Array[Tile] = []
	var config = dungeon.dungeon_config # Dungeonノードから設定を取得

	# 既に存在する上り階段を取得
	var up_stairs: Array[Tile] = map_data.filter_tiles(func(tile: Tile) -> bool:
		return tile.object_type == Enum.ObjectType.UP_STAIRS
	)

	# 候補地を探す
	var candidates: Array[Tile] = map_data.filter_tiles(func(tile: Tile) -> bool:
		if tile.terrain_type != Enum.TerrainTileType.FLOOR:
			return false
		if tile.object_type != Enum.ObjectType.NONE and tile.object_type != Enum.ObjectType.UP_STAIRS:
			return false

		# 上り階段からの距離チェック
		for up_stair in up_stairs:
			if up_stair.position.distance_to(tile.position) <= config.min_stair_distance:
				return false
		return true
	)

	candidates.shuffle()
	for i in range(min(number, candidates.size())):
		var tile = candidates[i]
		tile.set_object_type(Enum.ObjectType.DOWN_STAIRS)
		# 階段の下は床であることを保証
		tile.set_terrain_type(Enum.TerrainTileType.FLOOR)
		stair_tiles.append(tile)

	return stair_tiles

# -- ユーティリティ・旧メソッド群 --

# 指定された座標の隣接セル（縦横4方向）を取得する関数
func get_neighbors(x: int, y: int, width: int, height: int) -> Array:
	var neighbors: Array = []
	for dy in [-1, 0, 1]:
		for dx in [-1, 0, 1]:
			if abs(dx) == abs(dy): continue
			var nx = x + dx
			var ny = y + dy
			if nx >= 0 and nx < width and ny >= 0 and ny < height:
				neighbors.append([nx, ny])
	return neighbors

# 水平方向の通路を作成する関数
func carve_h_corridor(map: MapData, x1: int, x2: int, y: int) -> MapData:
	for x in range(min(x1, x2), max(x1, x2) + 1):
		if x >= 0 and x < map.width and y >= 0 and y < map.height:
			map.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.FLOOR)
	return map

# 垂直方向の通路を作成する関数
func carve_v_corridor(map: MapData, y1: int, y2: int, x: int) -> MapData:
	for y in range(min(y1, y2), max(y1, y2) + 1):
		if x >= 0 and x < map.width and y >= 0 and y < map.height:
			map.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.FLOOR)
	return map

# 部屋と通路をランダムに生成する関数（現在は未使用だが、別の生成モード用に保持）
func generate_rooms_and_corridors(map_data: MapData, room_count: int, room_min_size: int, room_max_size: int) -> MapData:
	var rooms: Array = []
	for i in range(room_count):
		var room_width = randi() % (room_max_size - room_min_size + 1) + room_min_size
		var room_height = randi() % (room_max_size - room_min_size + 1) + room_min_size
		var room_x = randi_range(1, map_data.width - room_width)
		var room_y = randi_range(1, map_data.height - room_height)
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
			_place_room(map_data, room_x, room_y, room_width, room_height)
			if rooms.size() > 0:
				var prev_room = rooms[rooms.size() - 1]
				var prev_cx = prev_room[0] + prev_room[2] / 2
				var prev_cy = prev_room[1] + prev_room[3] / 2
				@warning_ignore("integer_division")
				var cur_cx = room_x + room_width / 2
				@warning_ignore("integer_division")
				var cur_cy = room_y + room_height / 2
				if randi() % 2 == 0:
					map_data = carve_h_corridor(map_data, prev_cx, cur_cx, prev_cy)
					map_data = carve_v_corridor(map_data, prev_cy, cur_cy, cur_cx)
				else:
					map_data = carve_v_corridor(map_data, prev_cy, cur_cy, prev_cx)
					map_data = carve_h_corridor(map_data, prev_cx, cur_cx, cur_cy)
			rooms.append(new_room)
	return map_data

func _place_room(map_data: MapData, room_x: int, room_y: int, room_width: int, room_height: int) -> void:
	for y in range(room_y, room_y + room_height):
		for x in range(room_x, room_x + room_width):
			if x >= 0 and x < map_data.width and y >= 0 and y < map_data.height:
				map_data.get_tile_xy(x, y).set_terrain_type(Enum.TerrainTileType.FLOOR)
