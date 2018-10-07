import urllib
import cv2
import os
import hashlib

# pip install opencv-python

def download_image(url, saved_path=None):
    print("download_image/url:", url, ", saved_path:", saved_path)

    output_path = saved_path
    if saved_path is None:
        output_path = "./"

    if not os.path.exists(output_path):
        os.makedirs(output_path, exist_ok=True)

    file_name = os.path.basename(url)
    image_name, ext = os.path.splitext(file_name)

    # ファイル名が規則性がなく，上書きされないように，urlでハッシュ化しておく
    hashed_file_name = hashlib.sha1(url.encode('utf-8')).hexdigest()

    if ".jpg" in ext or ".jpeg" in ext:
        file_name = hashed_file_name + ".jpg"
    elif ".png" in ext:
        file_name = hashed_file_name + ".png"
    elif ".gif" in ext:
        file_name = hashed_file_name + ".gif"
    else:
        file_name = hashed_file_name + ".jpg"

    file_path = os.path.join(output_path, file_name)

    if os.path.exists(file_path):
        print("download_image/a image is already downloaded")
        return file_path


    try:
        any_url_obj = urllib.request.urlopen(url, timeout=30)
        local = open(file_path, 'wb')
        local.write(any_url_obj.read())
        any_url_obj.close()
        local.close()
        return file_path
    except Exception as e:
        print("error: ", str(e))
        return None


def path_inserted_directory(file_path, directory):
    dir_name = os.path.dirname(file_path)
    file_name = os.path.basename(file_path)
    path = os.path.join(dir_name, directory, file_name)
    return path

def path_inserted_basename_index(file_path, index):
    path, ext = os.path.splitext(file_path)
    path2 = path + "_" + str(index) + ext
    return path2


### OpenCV ###


def trim_image(image_path, rect, save_path=None):

    image = cv2.imread(image_path)
    if image is None:
        return None

    x = rect[0]
    y = rect[1]
    width = rect[2]
    height = rect[3]
    dst_image = image[y:y + height, x:x + width]
    if save_path is not None:
        os.makedirs(os.path.dirname(save_path), exist_ok=True)
        cv2.imwrite(save_path, dst_image)

    return dst_image


def rectangle_image(image_path, rect, border_color=None, save_path=None):

    image = cv2.imread(image_path)
    if image is None:
        return None

    color = (255, 255, 255)
    if border_color is not None:
        color = border_color

    dst_image = cv2.rectangle(image, tuple(rect[0:2]), tuple(rect[0:2] + rect[2:4]),
                              color, thickness=2)
    if save_path is not None:
        os.makedirs(os.path.dirname(save_path), exist_ok=True)
        cv2.imwrite(save_path, dst_image)

    return dst_image


def save_detected_faces(image_path, save_path=None, is_animeface=None):

    result = 0

    image = cv2.imread(image_path)
    if image is None:
        return result

    # サンプル顔認識特徴量ファイル
    cascade_path = "./haarcascades/haarcascade_frontalface_alt.xml"
    if is_animeface is not None and is_animeface == True:
        cascade_path = "./haarcascades/lbpcascade_animeface.xml"

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    cascade = cv2.CascadeClassifier(cascade_path)
    facerect = cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=1, minSize=(1, 1))

    output_path = save_path
    if save_path is None:
        output_path = path_inserted_directory(image_path, directory="0000_detected")

    result = len(facerect)
    print("detected faces =", result)
    if result > 0:
        # 検出した顔を囲む矩形の作成
        for i, rect in enumerate(facerect):
            temp_output_path = path_inserted_basename_index(output_path, i)
            trim_image(image_path=image_path, rect=rect, save_path=temp_output_path)
            # if save_path is not None:
            #     assert isinstance(image_path, str)
            #     trim_image(image_path=image_path, rect=rect, save_path=output_path)
            # else:
            #     rect_image = rectangle_image(image_path=image_path, rect=rect, save_path=output_path)
            #     show_cv_image(rect_image)

    return result


def show_cv_image(image):

    # 認識結果の表示
    cv2.imshow("temp.jpg", image)

    # 何かキーが押されたら終了
    while (1):
        if cv2.waitKey(10) > 0:
            break



def main():
    print("main")

    save_detected_faces(image_path="./img/Lenna.png", save_path="./img/Lenna2.png")


if __name__ == "__main__":
    main()
