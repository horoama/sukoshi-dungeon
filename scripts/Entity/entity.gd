class_name Entity
extends Sprite2D
# ゲーム内のマップ上に存在するオブジェクト（エンティティ）を表すクラス
#
# アクター（プレイヤー、敵）、アイテム、死体などの基底クラスとして機能します。
# 自身のグリッド座標を管理し、MapDataと連携して位置更新を行います。

enum AIType {NONE, HOSTILE}
enum EntityType {CORPSE, ITEM, ACTOR}

# エンティティ定義リソースへのパスマッピング
# TODO: これをFactoryクラスなどに分離することも検討
const entity_types = {
    "player" : "res://assets/definition/entity/actor/entity_definition_player.tres",
    "rice_ball" : "res://assets/definition/entity/item/entity_definition_rice_ball.tres",
    "skeleton" : "res://assets/definition/entity/actor/entity_definition_skeleton.tres",
}
var key: String

# マップ上のグリッド座標
# 値がセットされると、自動的にSprite2Dのpixel position（画面上の位置）も更新されます。
var grid_position: Vector2i:
    set(value):
        grid_position = value
        if map_data:
            position = map_data.tile_to_local(grid_position)

var _definition: EntityDefinition
var entity_name: String
var passable : bool = false   # 通行可能かどうか（falseなら障害物）
var transparent : bool = true # 視界を遮らないかどうか（trueなら透視可能）
var ai_type: AIType = AIType.NONE
var entity_type: EntityType = EntityType.ACTOR

# Entityは所属するMapDataを知っている必要がある
var map_data: MapData

# コンポーネント（戦闘、インベントリなど）
var fighter_component: FighterComponent
var inventory_component: InventoryComponent


# 初期化関数
#
# @param map_data: 所属するマップデータ
# @param grid_position: 初期配置するグリッド座標
# @param key: エンティティの種類を特定するキー（entity_typesのキー）
func _init(map_data: MapData, grid_position: Vector2i, key: String) -> void:
    centered = false
    flip_h = true
    self.map_data = map_data
    self.grid_position = grid_position
    set_entity_type(key)
    map_data.add_entity(grid_position, self)

# エンティティの種類を設定し、定義リソースからプロパティを読み込む関数
#
# 定義リソースに基づいて、名前、テクスチャ、通行可否、コンポーネントなどを設定します。
#
# @param key: エンティティの種類キー
func set_entity_type(key : String) -> void:
    self.key = key
    var entity_definition: EntityDefinition = load(entity_types[key])
    _definition = entity_definition
    entity_name = entity_definition.name
    name = entity_name
    texture = entity_definition.texture
    passable = entity_definition.passable
    transparent = entity_definition.transparent
    entity_type = entity_definition.type

    # コンポーネントの初期化
    if entity_definition.fighter_definition:
        fighter_component = FighterComponent.new(entity_definition.fighter_definition)
        add_child(fighter_component)
    if entity_definition.inventory_capacity > 0:
        inventory_component = InventoryComponent.new(entity_definition.inventory_capacity)
        add_child(inventory_component)


# 指定されたオフセットだけ移動する関数
#
# 移動先が通行可能かどうかを確認し、可能であれば座標を更新します。
# MapData上の登録位置も更新されます。
#
# @param offset: 移動量のベクトル (dx, dy)
func move(offset: Vector2i) -> void:
    # TODO: entityが存在していた場所がpasssibleだったかの確認は必要かも
    # TODO: 移動先についてもentity自体がpassibleか見る必要あり
    # TODO: map_data上にentityも置いてpassibleかのチェックをした方がよさそう
    if not map_data.is_passable(grid_position + offset):
        Loggie.info("Cannot move to %s; not passable." % (grid_position + offset))
        return

    # 移動処理：古い位置から削除し、新しい位置に追加
    map_data.remove_entity(grid_position, self)
    grid_position += offset
    map_data.add_entity(grid_position, self)