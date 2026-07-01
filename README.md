# habit_replacement_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


📂 プロジェクト構造 ＆ ディレクトリマップ
本プロジェクトの全体構成、およびAIを活用したマルチLLM検証環境のファイル配置図です。

🌲 ディレクトリ・ツリー
Plaintext
habit_replacement_app/         # プロジェクトルート（/Users/itachi-p/habit_replacement_app）
├── .github/                   # GitHub設定関連
├── android/                   # Android用自動生成フォルダ（今回は未使用）
├── ios/                       # iOS用自動生成フォルダ（今回は未使用）
├── web/                       # Webアプリ用設定・インデックスHTML
├── build/
│   └── web/                   # 【最重要】ビルド成果物（Vercelのデプロイ対象）
├── docs/                      # ★ドキュメント＆プロンプト管理フォルダ
│   ├── prompt_claude.md       # Claude 3.5 Sonnetへの投入プロンプト原本
│   ├── prompt_chatgpt.md      # ChatGPT (GPT-4o)への投入プロンプト原本
│   └── prompt_gemini.md       # Gemini 1.5 Proへの投入プロンプト原本
├── ai_backups/                # ★各LLMが生成したソースコードの読み取り専用保管庫
│   ├── main_claude.dart       # Claudeが最初に出力した高機能版ソース
│   ├── main_chatgpt.dart      # ChatGPTが出力したUI重視版ソース
│   └── main_gemini.dart       # Geminiが最初に出力したシンプル版ソース
├── lib/                       # ★Flutterソースコードのメイン格納庫
│   └── main.dart              # 【実行ターゲット】上記バックアップから選択して適用
├── pubspec.yaml               # プロジェクトの構成・依存パッケージ定義（supabase_flutter等）
└── README.md                  # 本プロジェクトの概要・起動マニュアル

📝 主要ファイル・フォルダの概要
1. lib/main.dart（実行実体）
Flutter Webが実際に読み込んで動作させる唯一のエントリーポイント。
ai_backups/ に格納されている3つのLLM（Claude / ChatGPT / Gemini）の成果物のうち、最も今回のプロトタイプに最適と判断したコードをここに全文コピペして実行します。

2. ai_backups/（マルチLLMコード保管庫）
ファイル名変更によるビルドトラップや予期せぬエラーを完全に防ぐため、実実行環境から隔離した「読み取り専用」のバックアップフォルダです。各AIの出力コードがそのまま無加工で保存されており、いつでも main.dart へ移し替えて検証が可能です。

3. docs/（プロンプト・エンジニアリング・ログ）
コードを生成させる際、AIに対してどのような制約条件（UI/UXの思想、TOCfEの組み込み、技術要件）を与えたかを記録したプロンプト原本です。「AIに丸投げした」のではなく、人間（篠原さん）が「意思を持ってAIをコントロールした」ドキュメンテーションとしての証拠になります。

4. build/web/（Vercelデプロイターゲット）
flutter build web --release コマンドによって生成される静的ファイル群。Vercelへデプロイする際、このフォルダを「Root Directory」に指定することで、BaaS（Supabase）と連携したFlutter Webアプリが瞬時にWeb上に公開されます。

