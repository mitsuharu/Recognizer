# readme.md


LoadImages.py

- 画像を読み込み可能に変換する
	- 画像データは以下のようなファイルで構成されると仮定する
	- カテゴリー名はフォルダーと一致

```
root_dir
 |- category1_dir
  |- image1
  |- image2
  |- ...
 |- category2_dir
 |- category3_dir
 |- ... 
```
 

ClassifyImages.py

- 機械学習
- 複雑なモデルではないのでCPU計算でも問題ないです
