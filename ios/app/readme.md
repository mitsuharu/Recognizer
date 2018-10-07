# CoreMLを用いた顔認識アプリ

- AVCaptureSessionでカメラ画像を逐次入力
- カメラ画像から顔を認識する
- 認識した画像をCoreMLで顔種類を認識する


## ビルド

- Xcode 10, iOS 11 以上
- 自身で学習したImageClassifier.mlmodelを追加する
- ```opencv2.framework``` を追加してください（[OpenCV](https://opencv.org/)）
- ```lbpcascade_animeface.xml```を追加してください（[lbpcascade_animeface](https://github.com/nagadomi/lbpcascade_animeface)）