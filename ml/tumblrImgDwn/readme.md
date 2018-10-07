# このプログラムについて

- Pythonを使って，各種APIやImageNetから画像をダウンロードします
	- Tumblr API
	- Google Image Search API
	- [ImageNet](http://www.image-net.org/ "ImageNet")（画像認識の大会の主催者）
- （オプション）顔画像認識を行い顔画像の切り出しを行います
	- オプションですが，```pip``` でインストールしてください

```
$ pip install opencv-python
$ pip install pillow
```

# トークンやAppKeysなど

- 各APIのkeyやtokenなどは ```AppKeys.py```にまとめて，適宜呼び出しています
- 個人的なtokenなのでgitには含まれてません

```
# tumblr
# https://www.tumblr.com/oauth/apps
# https://api.tumblr.com/console/calls/user/info

TUMBLR_CONSUMER_KEY = 'hogehoge'
TUMBLR_CONSUMER_SECRET = 'hogehoge'
TUMBLR_OAUTH_TOKEN = 'hogehoge'
TUMBLR_OAUTH_TOKEN_SECRET = 'hogehoge'

# Google Image Search
# http://qiita.com/onlyzs/items/c56fb76ce43e45c12339
# https://console.cloud.google.com/apis/api?project=imagesearchforml&organizationId=0
# https://cse.google.co.jp/cse/all

GOOGLE_API_KEY = "hogehoge"
```

## Tumblrのトークン

- [Applications](https://www.tumblr.com/oauth/apps "Tumblr")にて，アプリを登録して，Consumer KeyとSecret Keyを取得する
- [API Console](https://api.tumblr.com/console/calls/user/info "API Console | Tumblr")で上記keyを使って認証し，tokenを取得する（プログラムを書いて自身で認証してもよい）
- リクエスト上限は，1時間あたり1000リクエストかつ，1日5000リクエストまで

## Google Image Search

- [Google Custom Search APIを使って画像収集 - Qiita](http://qiita.com/onlyzs/items/c56fb76ce43e45c12339 "Google Custom Search APIを使って画像収集 - Qiita") に従って，カスタム検索APIの設定
- [Google Cloud Platform Console](https://console.cloud.google.com/apis) でCustom Search APIを有効にして，作成する
- 無料枠は1日あたり100リクエストまで．1リクエストで取得できる画像は10個なので，1日最大1000個．



# Tumblrから画像をダウンロードする

- Tumblrに投稿された画像を取得する
- 個人のアップロードなので趣向に偏りあり

必須

```
$ pip install python-tumblpy
```

実行

```
TumblrImageDownloader.download_images_from_tumblr(tag,
 	max_count=10, 
 	before_timestamp=None, 
 	saved_path=None, 
 	is_face_detect=None, 
 	is_animeface=None)
```

| 引数 | 種類 | 説明 |
| :-: | :-: | :-- |
| tag | 文字列 | タグもしくは検索ワード（必須） |
| max_count | 整数 | ダウンロード数の目安 |
| before_timestamp | 整数 | 検索対象の時間を指定する（ページング） |
| saved_path | 文字列 | ダウンロードした画像の保存場所．「./hogehoge」など．Noneの場合は自動でフォルダーが生成される |
| is_face_detect | bool | 顔認識および切り取り保存を行う場合はTrue |
| is_animeface | bool | 顔がアニメ顔ならTrue（認識制度のため） |

戻り値

```
return dl_count, fc_count, last_timestamp
```

| 引数 | 種類 | 説明 |
| :-: | :-: | :-- |
| dl_count | 整数 | ダウンロードした数 |
| fc_count | 整数 | 顔認識して切り出した数 |
| last_timestamp | 整数 | 最終のタイムスタンプ（次ページングの指標） |

# Google Image Searchから画像をダウンロードする

- Google画像検索の画像結果が取得できる
- Tumblrに対して，比較的バラついてる感じ

実行

```
GoogleImageDownloader.download_images_from_google(tag,
	max_count=10, 
 	before_index=None, 
	saved_path=None, 
	is_face_detect=None, 
	is_animeface=None)
```

| 引数 | 種類 | 説明 |
| :-: | :-: | :-: |
| tag | 文字列 | タグもしくは検索ワード（必須） |
| max_count | 整数 | ダウンロード数の目安 |
| before_index | 整数 | 検索対象のページインデックスを指定する（ページング） |
| saved_path | 文字列 | ダウンロードした画像の保存場所．「./hogehoge」など．Noneの場合は自動でフォルダーが生成される |
| is_face_detect | bool | 顔認識および切り取り保存を行う場合はTrue |
| is_animeface | bool | 顔がアニメ顔ならTrue（認識制度のため） |

戻り値

```
return dl_count, fc_count, index
```

| 引数 | 種類 | 説明 |
| :-: | :-: | :-- |
| dl_count | 整数 | ダウンロードした数 |
| fc_count | 整数 | 顔認識して切り出した数 |
| index | 整数 | 最終のページインデックス（次ページングの指標） |

# ImageNetから画像をダウンロードする

- 約1400万枚の画像データ（2万2千カテゴリ）あるらしい
- 出どころが様々なサイトでライセンス怪しいので，あまり外に出さない
- 顔認識検出機能は付けてないです

実行

```
ImagenetDownloader.download_images_from_imageset(image_class=1000, 
	pictures=100,
	saved_path=None):
```

| 引数 | 種類 | 説明 |
| :-: | :-: | :-- |
| image_class | 数字 | クラス数 |
| pictures | 数字 | 1クラスあたりの画像数 |
| saved_path | 文字列 | ダウンロードした画像の保存場所．「./hogehoge」など．Noneの場合は自動でフォルダーが生成される |

---

# 付録

### Tumblpy

- TumblrのPython向け公式SDKはPython3に対応していないので，[Tumblpy](https://github.com/michaelhelmick/python-tumblpy "michaelhelmick/python-tumblpy: A Python Library to interface with Tumblr v2 REST API &amp; OAuth")を使用しています

```
$ pip install python-tumblpy
```

### OpenCV

- 顔認識にはOpenCVを使用しています

```
$ pip install opencv-python
```

### その他のメソッド

```ImageUtility.download_image(url, saved_path=None)```

- ```url```で指定した画像をダウンロードします．
- ```saved_path```で保存するフォルダーを指定できます．```None```の場合は，実行したディレクトリ直下に保存ディレクトリが作成されます．
- 画像ファイル名は重複を防ぐため，```url```をsha1でハッシュ化したものを使用し，そのファイル名（ディレクトリ含む）が返り値として取得できます．また，404など場合は```False```が返り値になります．


```ImageUtility.save_detected_faces(image_path, save_path=None, is_animeface=None)```

- ```image_path```にある画像に対して，OpenCVの顔認識を行い，検出した顔領域を切り出し保存します．
- ```saved_path```で保存するフォルダーを指定します．```None```の場合は，入力画像の同階層にフォルダーを生成し，そのフォルダーに保存します．
- 対象がアニメ顔の場合は```is_animeface```に```True```を設定してください
- 検出した顔領域の数を返り値として取得できます．



---
# リンク

- [大規模画像データセット - n_hidekeyの日記](http://d.hatena.ne.jp/n_hidekey/20120115/1326613794 "大規模画像データセット - n_hidekeyの日記")