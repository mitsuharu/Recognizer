# -*- coding: utf-8 -*-

#
# 画像を読み込んでデータ化する
#

import os
import numpy as np
from PIL import Image
import pickle
import random

IMAGE_WIDTH = 28
IMAGE_HEIGHT = 28


class ImageData:
    def __init__(self):
        self.x_train = None
        self.x_test = None
        self.y_train = None
        self.y_test = None
        self.category_names = []
        self.img_rows = IMAGE_WIDTH
        self.img_cols = IMAGE_HEIGHT


def is_image_file_name(file_name):
    is_image_file = False
    _, ext = os.path.splitext(file_name)
    if ".jpg" in ext or ".jpeg" in ext or ".png" in ext:
        is_image_file = True

    return is_image_file


def make_output_path(root_dir= "./", save_path=None):

    # 保存名
    output_path = save_path
    if save_path is None:
        temp_path = os.path.dirname(root_dir)
        temp_name = "./image_data.pickle"
        if root_dir != "./":
            temp_name = os.path.basename(root_dir) + ".pickle"
        output_path = os.path.join(temp_path, temp_name)

    return output_path


def calc_image_data(file_path):

    _, ext = os.path.splitext(file_path)

    mode = "L"
    # if ".png" in ext:
    #     mode = "P"

    image = Image.open(file_path).convert(mode)
    image = image.resize((IMAGE_WIDTH, IMAGE_HEIGHT), Image.ANTIALIAS)
    data = np.asarray(image, dtype=float)
    data /= 255
    data = data.astype('float32')
    data = data.reshape(1, IMAGE_WIDTH, IMAGE_HEIGHT, 1)

    return data

"""
* 画像データは以下のようなファイルで構成されると仮定する
* カテゴリー名はフォルダーと一致

root_dir
 |- category1
  |- image1
  |- image2
  |- ...
 |- category2
 |- category3
 |- ... 

"""
def load_images(root_dir="./"):

    input_data = None
    output_data = None
    category_names = []

    # delete .DS_Store
    os.system('find . -name .DS_Store | xargs rm')

    for i, name0 in enumerate(os.listdir(root_dir)):
        # print("name:", name0)

        path0 = os.path.join(root_dir, name0)
        if os.path.isdir(path0):
            category_names.append(name0)

            for name1 in os.listdir(path0):

                if is_image_file_name(name1) == False:
                    break

                path1 = os.path.join(path0, name1)

                if os.path.isfile(path1):

                    if output_data is None:
                        output_data = np.array([i])
                        output_data = output_data.reshape(1, 1)
                    else:
                        output_data = np.append(output_data, i)

                    data = calc_image_data(path1)
                    # print("data:", data.shape)

                    if input_data is None:
                        input_data = data
                    else:
                        input_data = np.append(input_data, data, axis=0)


    return input_data, output_data, category_names


"""
"""
def make_image_data(root_dir="./", save_path=None):
    print("save_image_data/root_dir:{} save_path:{}".format(root_dir, save_path))

    # 保存名
    output_path = make_output_path(root_dir=root_dir, save_path=save_path)

    # 計算結果
    input_data, output_data, category_names = load_images(root_dir=root_dir)

    # 出力作成
    result = ImageData()
    result.category_names = category_names

    # シャッフルと分割
    indexes = np.random.permutation(input_data.shape[0])
    indexes_split = np.array_split(indexes, 2)

    result.x_train = input_data[indexes_split[0]]
    result.x_test = input_data[indexes_split[1]]
    result.y_train = output_data[indexes_split[0]]
    result.y_test = output_data[indexes_split[1]]

    with open(output_path, mode='wb') as f:
        pickle.dump(result, f)

    return None


def make_image_data_for_train_and_test(train_dir: str, test_dir: str, save_file: str):
    print("make_image_data_for_train_and_test/train_dir:{}, test_dir:{} save_file:{}".format(train_dir, test_dir, save_file))

    # 保存名
    output_path = "./make_image_data_for_train_and_test.pickle"

    # 計算結果
    input_data0, output_data0, category_names0 = load_images(root_dir=train_dir)
    input_data1, output_data1, category_names1 = load_images(root_dir=test_dir)

    # 一致判定
    is_equal = (category_names0 == category_names1)
    print("is_equal:{}".format(is_equal))
    if is_equal == False:
        print("error")
    else:
        # 出力作成
        result = ImageData()
        result.category_names = category_names0
        result.x_train = input_data0
        result.x_test = input_data1
        result.y_train = output_data0
        result.y_test = output_data1

        print("result.x_train:", result.x_train.shape)
        print("result.y_train:", result.y_train.shape)
        print("result.x_test:", result.x_test.shape)
        print("result.y_test:", result.y_test.shape)

        os.makedirs(os.path.dirname(save_file), exist_ok=True)
        with open(save_file, mode='wb') as f:
            pickle.dump(result, f)

    return is_equal


def load_image_data_from(filePath="./imagedata.pickle") -> ImageData:

    result = None

    try:
        with open(filePath, mode='rb') as f:
            result = pickle.load(f)
    except Exception as e:
        print("error: ", str(e))

    return result


def cast(obj, class_name):
    obj.__class__ = class_name


if __name__ == "__main__":
    print("main")

    make_image_data_for_train_and_test(train_dir="./train",
                                       test_dir="./test",
                                       save_file="./hogehoge.pickle")

