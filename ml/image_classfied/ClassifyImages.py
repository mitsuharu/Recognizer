# -*- coding: utf-8 -*-

import keras
from keras.models import Sequential, load_model
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D
from keras import backend as K
import os.path
import shutil
from keras.callbacks import *

from LoadImages import ImageData, load_image_data_from, calc_image_data

batch_size = 128
num_classes = 2
epochs = 1000
img_rows = 28
img_cols = 28

"""
https://stackoverflow.com/questions/37293642/how-to-tell-keras-stop-training-based-on-loss-value
https://github.com/fchollet/keras/issues/114
"""

class EarlyStoppingByLossVal(Callback):
    def __init__(self, monitor='val_loss', value=0.01, verbose=0):
        super(Callback, self).__init__()
        self.monitor = monitor
        self.value = value
        self.verbose = verbose

    def on_epoch_end(self, epoch, logs={}):
        current = logs.get(self.monitor)
        if current is None:
            warnings.warn("Early stopping requires %s available!" % self.monitor, RuntimeWarning)

        if current < self.value:
            if self.verbose > 0:
                print("Epoch %05d: early stopping THR" % epoch)
            self.model.stop_training = True


def learning_model(input_path=None, output_path=None):
    print("learning_model/input_path:", input_path, ", output_path:", output_path)

    # 入力データ
    file_path = input_path
    if input_path is None:
        file_path = "./imagedata.pickle"

    # セーブデータ
    saved_model_file_path = output_path
    if output_path is None:
        temp_dir = os.path.dirname(file_path)
        temp_file_path, _ = os.path.splitext(os.path.basename(file_path))
        temp_name = os.path.basename(temp_file_path) + ".h5"
        saved_model_file_path = os.path.join(temp_dir, temp_name)

    print("saved_model_file_path:", saved_model_file_path)

    image_data = load_image_data_from(file_path)
    # image_data.__class__ = ImageData
    print("category_names:", image_data.category_names)

    x_train = image_data.x_train
    y_train = image_data.y_train
    x_test = image_data.x_test
    y_test = image_data.y_test

    num_classes = len(image_data.category_names)
    img_rows = image_data.img_rows
    img_cols = image_data.img_cols

    # convert class vectors to binary class matrices
    y_train = keras.utils.to_categorical(y_train, num_classes)
    y_test = keras.utils.to_categorical(y_test, num_classes)

    input_shape = (img_rows, img_cols, 1)

    model = Sequential()
    model.add(Conv2D(32,
                     kernel_size=(3, 3),
                     activation='relu',
                     input_shape=input_shape))
    model.add(Conv2D(64, (3, 3), activation='relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))
    model.add(Dropout(0.25))
    model.add(Flatten())
    model.add(Dense(128, activation='relu'))
    model.add(Dropout(0.5))
    model.add(Dense(num_classes, activation='softmax'))

    model.compile(loss=keras.losses.categorical_crossentropy,
                  optimizer=keras.optimizers.Adadelta(),
                  metrics=['accuracy'])

    # コールバック
    callbacks = []


    # か学習防止
    # http://qiita.com/yukiB/items/f45f0f71bc9739830002#earlystopping
    # cb_es = keras.callbacks.EarlyStopping(monitor='val_loss', min_delta=0, patience=30, verbose=1, mode='auto')

    cb_es1 = keras.callbacks.EarlyStopping(monitor='loss', min_delta=0.01, patience=10, verbose=1)
    callbacks.append(cb_es1)

    cb_es2 = EarlyStoppingByLossVal(monitor='val_loss', value=0.10, verbose=1)
    # https://keras.io/ja/getting-started/faq/#validation-loss
    # early_stopping = EarlyStopping(monitor='val_loss', patience=2)
    callbacks.append(cb_es2)

    # tensor board
    try:
        tb_Path = "./log"
        if os.path.exists(tb_Path):
            shutil.rmtree(tb_Path)
        os.makedirs(tb_Path, exist_ok=True)
        tb_cb = keras.callbacks.TensorBoard(log_dir=tb_Path, histogram_freq=1, write_graph=True)
        callbacks.append(tb_cb)
    except Exception as e:
        print("error: ", str(e))

    # 保存
    try:
        period = 10
        # if epochs > 100:
        #     period = epochs/100

        temp_ck_name, _ = os.path.splitext(os.path.basename(file_path))
        checkpoint_path = "./checkpoint_" + temp_ck_name
        if os.path.exists(checkpoint_path):
            shutil.rmtree(checkpoint_path)
        os.makedirs(checkpoint_path, exist_ok=True)

        hdf5_name = 'weights.epoch{epoch:02d}-loss{loss:.2f}-acc{acc:.2f}-val_loss{val_loss:.2f}-val_acc{val_acc:.2f}.hdf5'
        cp_file_path = os.path.join(checkpoint_path, hdf5_name)
        cp_cb = keras.callbacks.ModelCheckpoint(cp_file_path,
                                                monitor='val_loss',
                                                verbose=0,
                                                save_best_only=False,
                                                save_weights_only=False,
                                                mode='auto',
                                                period=period)
        callbacks.append(cp_cb)
    except Exception as e:
        print("error: ", str(e))

    print("学習開始")
    model.fit(x_train,
              y_train,
              batch_size=batch_size,
              epochs=epochs,
              verbose=1,
              validation_data=(x_test, y_test),
              callbacks=callbacks)

    print("\nevaluate")
    score = model.evaluate(x_test, y_test, verbose=0)
    print('Test loss:', score[0])
    print('Test accuracy:', score[1])

    # 保存
    os.makedirs(os.path.dirname(saved_model_file_path), exist_ok=True)
    model.save(saved_model_file_path)

    return saved_model_file_path

"""
画像の推定
"""
def estimate_image(image_path, learned_model_file_path, image_data_path=None):
    print("estimate_image/input_path:", image_path, ", model_file_path:", model_file_path)

    # 画像データからカテゴリー名を取得する
    category_names = None
    if image_data_path is not None:
        image_data = load_image_data_from(image_data_path)
        image_data.__class__ = ImageData
        category_names = image_data.category_names
        print("category_names:", category_names)

    # 入力画像のデータ化
    image_data = calc_image_data(image_path)

    # モデル生成
    model = load_model(learned_model_file_path)

    # 入力予測
    classes = model.predict_classes(image_data, batch_size=32)
    # proba = model.predict_proba(image_data, batch_size=32)
    # print("proba = ", proba)

    if category_names is not None:
        try:
            for cls in classes:
                print("class:", cls, "category_name = ", category_names[cls])
        except Exception as e:
            print("error: ", str(e))
            print("classes = ", classes)
    else:
        print("classes = ", classes)


if __name__ == "__main__":
    print("main")

    input_path = "./hogehoge.pickle"
    model_file_path = "./hogehoge.h5"

    learning_model(input_path=input_path, output_path=model_file_path)
    estimate_image(image_path="./hogehoge.png",
                   learned_model_file_path=model_file_path,
                   image_data_path=input_path)



