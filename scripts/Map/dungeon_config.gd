extends Resource
class_name DungeonConfig

# マップの幅
@export var map_width: int = 40
# マップの高さ
@export var map_height: int = 30
# 初期の壁の割合
@export var wall_rate: float = 0.45
# セルオートマトンのシミュレーション回数
@export var simulation_steps: int = 3
# 部屋生成の試行回数
@export var room_attempts: int = 3
# 部屋の最小サイズ
@export var room_min_size: int = 3
# 部屋の最大サイズ
@export var room_max_size: int = 6
# セルオートマトンの生存閾値（壁が維持されるのに必要な周囲の壁の最小数）
@export var survival_limit: int = 4
# セルオートマトンの誕生閾値（床が壁になるのに必要な周囲の壁の最小数）
@export var birth_limit: int = 5
# 階段間の最小距離
@export var min_stair_distance: int = 20
