class_name ObjectPlacer
extends RefCounted

static func finalize_map(dungeon_node: Node, map_data: MapData) -> Array[Tile]:
    # ここに最終的なマップ調整のコードを追加
    _place_item(dungeon_node, map_data)
    return set_next_stairs(map_data, 1)

static func _place_item(dungeon_node: Node, map_data: MapData) -> void:
    # TODO: randomな位置にアイテムを配置するコードを追加
    ## ダミーとして1つのアイテムを配置
    var emptys = map_data.filter_tiles(func(tile: Tile) -> bool:
        return tile.terrain_type == Enum.TerrainTileType.FLOOR and tile.object_type == Enum.ObjectType.NONE
    )
    if emptys.size() > 0:
        emptys.shuffle()
        var selected = emptys[0]
        # Entity class needs to be available. Since this is a static function, we might need to be careful with `Entity.new`.
        # Assuming Entity is a global class_name.
        var item = Entity.new(map_data, selected.position, "rice_ball")
        # dungeon_node needs to have `add_entity_to_map` method.
        if dungeon_node.has_method("add_entity_to_map"):
            dungeon_node.add_entity_to_map(map_data, selected.position, item)

static func set_next_stairs(map_data: MapData, number: int) -> Array[Tile]:
    # 階段を設置するコードを追加
    var empty_tiles: Array[Tile] = []
    var stair_tiles: Array[Tile] = []
    var up_stairs: Array[Tile] = map_data.filter_tiles(func(tile: Tile) -> bool:
        return tile.object_type == Enum.ObjectType.UP_STAIRS
    )
    for tile in map_data.tiles:
        # 階段設置用の空きタイルを収集
        if tile.terrain_type == Enum.TerrainTileType.FLOOR or tile.object_type == Enum.ObjectType.UP_STAIRS:
            # UP_STAIRSから10タイル以内のタイルは除外
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
