extends Node
# ゲーム全体のグローバルな状態を管理するシングルトン
#
# シーンを跨いで保持すべきデータや、グローバルなゲーム進行（ターン管理など）
# を担当することを想定しています。
# プロジェクト設定の Autoload で登録されています。

var player_instance = null
var enemies_list = []

# 新規ゲームを開始する際の処理
#
# 現在はプレースホルダーですが、将来的にセーブデータのリセットや
# 初期状態のセットアップを行う予定です。
func start_new_game():
    Loggie.info("Starting new game")
    pass

# プレイヤーのターン終了時の処理
#
# 現在はプレースホルダーですが、敵のAI思考ルーチンの呼び出しや
# ターン経過による状態変化の更新などを行う予定です。
func end_player_turn():
    pass

func _ready():
    Loggie.info("GameManager initialized")
