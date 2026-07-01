# 3週間 新習慣置き換えチャレンジ（プロトタイプ）

本プロジェクトは、株式会社シー・アンド・シー・ワークス様の「ITを使う楽しさを世の中に伝える」という理念、および「UI/UXの提案」というテーマに対し、1時間という限られた時間の中で企画からデプロイまでを爆速でコミットしたFlutter Webのプロトタイプです。

## 🛠️ 開発思想（AI共創型アプローチ）
単にひとつのAIに依存するのではなく、**Claude 3.5 Sonnet、ChatGPT (GPT-4o)、Gemini 1.5 Pro** の3つの主要LLMに対して同一のプロンプトを投入。出力されたコードのモダニティ、アニメーションの滑らかさ、エラーの少なさを比較検証するアプローチを採用しました。

- `lib/main_claude.dart` : Claude (Sonnet5) 出力版
- `lib/main_chatgpt.dart` : ChatGPT (GPT-5.5) 出力版
- `lib/main_gemini.dart` : Gemini (3.5 Flash) 出力版 -> 3.1 Proの方がよさげ？
※各プロンプトの原本は `docs/` ディレクトリに格納しています。

## 🎯 UI/UXのこだわり（TOCfEの思想をベースに）
- **「置き換え」のUX**: 悪習慣を単に「禁止」するのではなく、代替となる新習慣へ行動を「置き換える」ことで心理的負荷を軽減（行動科学・TOCの対立解消アプローチ）。
- **「梅（気づけた）」ボタンの救済**: 三日坊主を防ぐため、「つい悪習慣が出た」という失敗時（梅）であっても、アプリはユーザーを責めず「メタ認知できた（自覚できた）だけで大前進！」とポジティブなアニメーションで褒め称える設計。

## 💻 爆速環境構築＆デプロイ手順（検証用ログ）
今回はモバイルエミュレーターの重たいセットアップ（Xcode/Android Studio）をスキップし、もっとも軽量で配信コストの低い「Flutter Web」にターゲットを絞って検証を行いました。

### 1. 環境構築＆プロジェクト作成
```bash
brew install --cask flutter
flutter config --enable-web
cd ~/repos
flutter create --platforms web habit_replacement_app
cd habit_replacement_app
flutter pub add supabase_flutter
