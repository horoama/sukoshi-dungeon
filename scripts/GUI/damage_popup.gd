class_name DamagePopup
extends Label
# ダメージや回復時に表示されるポップアップのUIコンポーネント
#
# エンティティの頭上に数値を表示し、上方に移動しながらフェードアウトします。
# アニメーション終了後に自身を削除します。

const FONT_SIZE: int = 24
const ANIMATION_DURATION: float = 1.0
const MOVE_DISTANCE: float = 30.0

# 初期化関数
#
# @param amount_text: 表示するテキスト（ダメージ量や回復量など）
# @param color: テキストの色
func _init(amount_text: String, color: Color) -> void:
    text = amount_text
    label_settings = LabelSettings.new()
    label_settings.font_color = color
    label_settings.font_size = FONT_SIZE
    label_settings.outline_size = 2
    label_settings.outline_color = Color.BLACK

    # 中央揃え
    horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _ready() -> void:
    # エンティティは32x32ピクセルで左上原点 (centered=false)
    # ラベルの幅をタイルサイズと同じにし、中央揃えを効かせる
    custom_minimum_size = Vector2(32, 0)
    # 基準位置を調整（タイルの左上から、Y軸のみ上にオフセット）
    position = Vector2(0, -20)

    # Tweenを作成してアニメーションを実行
    var tween: Tween = create_tween()

    # 上に移動させるアニメーション
    tween.tween_property(self, "position:y", position.y - MOVE_DISTANCE, ANIMATION_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

    # 同時に透明度を下げてフェードアウトさせるアニメーション
    tween.parallel().tween_property(self, "modulate:a", 0.0, ANIMATION_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

    # アニメーション終了時に自身を削除
    tween.tween_callback(queue_free)
