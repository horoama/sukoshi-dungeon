extends RefCounted

class_name TileDefine

const TerrainTile : Dictionary = {
    "FLOOR" : {
        "ATLAS_ID": 0,
        "ATLAS_COORDS": Vector2(0, 0),
    },
    "WALL" : {
        "ATLAS_ID": 0,
        "ATLAS_COORDS": Vector2(0, 1),
    },
}
const ObjectTile : Dictionary = {
    "NONE": {
        "ATLAS_ID": 1,
        "ATLAS_COORDS": Vector2(-1, -1),
    },
    "DOWN_STAIRS": {
        "ATLAS_ID": 1,
        "ATLAS_COORDS": Vector2(7, 16),
    },
}

func get_tile(tile_type: String, layer_name: String) -> Dictionary:
    if layer_name == "Terrain":
        return TerrainTile[tile_type]
    elif layer_name == "Object":
        return ObjectTile[tile_type]
    else:
        return {}