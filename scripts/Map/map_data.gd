class_name MapData
# マップデータを管理するクラス
#
# グリッド状のタイルデータ、配置されているアクター、アイテムなどを保持します。
# また、座標変換や通行可能判定などのユーティリティメソッドも提供します。

var TILE_SIZE = 32
var level: int
var width: int  # マップの幅（タイル数）
var height: int # マップの高さ（タイル数）
var tiles: Array[Tile]= []  # 1次元配列として格納されたタイルデータ
var actors: Dictionary[Vector2i, Entity] = {} # グリッド座標をキーとしたアクターの辞書
var items: Dictionary[Vector2i, Array] = {} # グリッド座標をキーとしたアイテム配列の辞書

signal map_updated # マップの状態が変更されたときに発行されるシグナル

# 初期化関数
#
# 指定されたサイズと階層でマップを初期化し、すべて壁で埋めます。
#
# @param map_width: マップの幅
# @param map_height: マップの高さ
# @param map_level: 階層（深度）
func _init(map_width: int, map_height: int, map_level: int) -> void:
    tiles = []
    self.width = map_width
    self.height = map_height
    self.level = map_level
    fill_map(Enum.TerrainTileType.WALL)
    # signal emit
    map_updated.emit()

func add_entity(grid_pos: Vector2i, entity: Entity) -> void:
    if entity.entity_type == Entity.EntityType.ACTOR:
        actors[grid_pos] = entity
    elif entity.entity_type == Entity.EntityType.ITEM:
        if not items.has(grid_pos):
            items[grid_pos] = []
        items[grid_pos].append(entity)

func remove_entity(grid_pos: Vector2i, entity: Entity) -> void:
    if entity.entity_type == Entity.EntityType.ACTOR:
        if actors.has(grid_pos) and actors[grid_pos] == entity:
            actors.erase(grid_pos)
    elif entity.entity_type == Entity.EntityType.ITEM:
        if items.has(grid_pos):
            items[grid_pos].erase(entity)
            if not items[grid_pos]:
                items.erase(grid_pos)

func fill_map(terrain_tile_type: Enum.TerrainTileType) -> void:
    tiles.clear()
    for y in range(height):
        for x in range(width):
            var tile = Tile.new(Vector2i(x, y), terrain_tile_type)
            tiles.append(tile)

func get_tile_xy(x: int, y: int) -> Tile:
    var index = grid_to_index(Vector2i(x, y))
    if index >= 0 and index < tiles.size():
        return tiles[index]
    return null

func get_tile(pos: Vector2i) -> Tile:
    return get_tile_xy(pos.x, pos.y)

func filter_tiles(func_ref: Callable) -> Array[Tile]:
    var result: Array[Tile] = []
    for tile in tiles:
        if func_ref.call(tile):
            result.append(tile)
    return result

func set_tile(pos: Vector2i, tile: Tile) -> void:
    var index = grid_to_index(pos)
    if index >= 0 and index < tiles.size():
        tiles[index] = tile
    map_updated.emit()

func change_terrain_tile_type(pos: Vector2i, tile_code: Enum.TerrainTileType) -> void:
    var tile = get_tile(pos)
    if tile:
        tile.set_terrain_type(tile_code)

func change_object_tile_type(pos: Vector2i, tile_code: Enum.ObjectType) -> void:
    var tile = get_tile(pos)
    if tile:
        tile.set_object_type(tile_code)

# グリッド座標(x, y)を1次元配列のインデックスに変換します
#
# @param grid_pos: グリッド座標
# @return: 1次元配列のインデックス
func grid_to_index(grid_pos: Vector2i) -> int:
    # TODO: Add bounds checking
    return grid_pos.x + grid_pos.y * width

# 1次元配列のインデックスをグリッド座標(x, y)に変換します
#
# @param index: 1次元配列のインデックス
# @return: グリッド座標
func index_to_grid(index: int) -> Vector2i:
    var x = index % width
    @warning_ignore("integer_division")
    var y = index / width
    return Vector2i(x, y)

# 指定された座標が通行可能かどうかを判定します
#
# 地形（壁など）、アイテム、アクターの通行可否をすべてチェックし、
# 移動可能であれば true を返します。
#
# @param grid_pos: チェックするグリッド座標
# @return: 通行可能な場合 true
func is_passable(grid_pos: Vector2i) -> bool:
    var tile = get_tile(grid_pos)
    if not tile or not tile.passable:
        return false
    for item in items.get(grid_pos, []):
        if not item.passable:
            return false
    if actors.get(grid_pos, null):
        if not actors.get(grid_pos).passable:
            return false
    return true

func is_transparent(grid_pos: Vector2i) -> bool:
    var tile = get_tile(grid_pos)
    if not tile or not tile.transparent:
        return false
    for item in items.get(grid_pos, []):
        if not item.transparent:
            return false
    if actors.get(grid_pos, null):
        if not actors.get(grid_pos).transparent:
            return false
    return true

func reveal_tile(grid_pos: Vector2i) -> void:
    var tile = get_tile(grid_pos)
    if tile and tile.state == Enum.TileStatus.HIDDEN:
        tile.state = Enum.TileStatus.VISIBLE
        map_updated.emit()

# グリッド座標をローカル座標（ピクセル単位）に変換します
#
# エンティティの表示位置の計算などに使用されます。
#
# @param pos: グリッド座標
# @return: ローカル座標
func tile_to_local(pos: Vector2i) -> Vector2:
    var local_pos = Vector2(pos.x * TILE_SIZE, pos.y * TILE_SIZE)
    return local_pos

# TODO: for ASTAR pathfinding
func _update_blocking_info(grid_pos: Vector2i) -> void:
    # TODO: for ASTAR pathfinding
    var tile = get_tile(grid_pos)
    var passable = tile.passable
    for entity in tile.get_entities():
        if not entity.passable:
            passable = false
    if passable:
        # mark as non-blocking
        pass
    else:
        # mark as blocking
        pass

func update_visuals() -> void:
    map_updated.emit()
