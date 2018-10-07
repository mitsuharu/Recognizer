# -*- coding: utf-8 -*-

##############
#
# 無料使用枠は100リクエスト/日
# 1リクエストで最大10程度取得可能なので，1日最大1000件まで
#
##############

import urllib.request
from urllib.parse import quote
import json
import time
from ImageUtility import download_image, save_detected_faces
import AppKeys

# http://qiita.com/onlyzs/items/c56fb76ce43e45c12339
# https://console.cloud.google.com/apis/api?project=imagesearchforml&organizationId=0
# https://cse.google.co.jp/cse/all

API_KEY = AppKeys.GOOGLE_API_KEY
CUSTOM_SEARCH_ENGINE = AppKeys.GOOGLE_CUSTOM_SEARCH_ENGINE


def download_images_from_google(tag, max_count=10, before_index=None, saved_path=None, is_face_detect=None, is_animeface=None):

    dl_count = 0
    fc_count = 0

    if max_count > 1000:
        max_count = 1000

    output_path = saved_path
    if saved_path is None:
        output_path = "./dl_google/" + tag

    index = 0
    if before_index is not None:
        index = before_index

    while dl_count < max_count:
        query_img = "https://www.googleapis.com/customsearch/v1?key=" + API_KEY + "&cx=" + CUSTOM_SEARCH_ENGINE + "&num=10" + "&start=" + str(index + 1) + "&q=" + quote(
            tag) + "&searchType=image"

        # print("query_img:", query_img)
        data = None
        try:
            res = urllib.request.urlopen(query_img)
            data = json.loads(res.read().decode('utf-8'))
        except Exception as e:
            print("error: ", str(e))

        #print("data:", data)

        if data == None or len(data) == 0:
            print("end: data is void")
            break

        if data is not None and "items" in data:
            items = data["items"]
            index = index + len(items)
            for item in items:
                image_url = item["link"]
                file_path = download_image(image_url, output_path)
                if file_path:
                    dl_count += 1
                    if is_face_detect is not None:
                        fc_count += save_detected_faces(image_path=file_path, is_animeface=is_animeface)
        else:
            break

    return dl_count, fc_count, index


if __name__ == "__main__":

    # tag = "西住まほ"
    #tag = "エロマンガ先生"

    tag = "涼風青葉"
    tag = "滝本ひふみ"
    tag = "八神コウ"
    tag = "篠田はじめ"
    tag = "飯島ゆん"
    tag = "桜ねね"
    tag = "阿波根うみこ"
    tag = "遠山りん"
    # tag = "葉月しずく"


    tag = "志摩リン"
    tag = "shima rin"
    # tag = "各務原なでしこ"
    tag = "kagamihara nadeshiko"
    # tag = "斉藤恵那"
    # tag = "saitou ena"
    # tag = "大垣千明"
    # tag = "oogaki chiaki"
    # tag = "犬山あおい"
    # tag = "inuyama aoi"

    is_animeface = True

    # 無料使用枠は100リクエスト/日かつ1リクエストで最大10程度取得可能なので，1日最大1000件まで
    max_count = 100

    index = None

    calc_time = time.time()
    dl_count, fc_count, index = download_images_from_google(tag=tag,
                                                            max_count=max_count,
                                                            before_index=index,
                                                            is_face_detect=True,
                                                            is_animeface=is_animeface)
    calc_time = time.time() - calc_time
    print("dl_count:", dl_count, ", fc_count:", fc_count, ", index:", index, ", calc_time:", calc_time, "sec")