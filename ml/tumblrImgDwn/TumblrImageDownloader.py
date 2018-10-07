# -*- coding: utf-8 -*-
from tumblpy import Tumblpy
from ImageUtility import download_image, save_detected_faces
import time
import AppKeys


# https://github.com/michaelhelmick/python-tumblpy

# https://www.tumblr.com/oauth/apps
# https://api.tumblr.com/console/calls/user/info
CONSUMER_KEY = AppKeys.TUMBLR_CONSUMER_KEY
CONSUMER_SECRET = AppKeys.TUMBLR_CONSUMER_SECRET
OAUTH_TOKEN = AppKeys.TUMBLR_OAUTH_TOKEN
OAUTH_TOKEN_SECRET = AppKeys.TUMBLR_OAUTH_TOKEN_SECRET



def authorize():
    print("func authorize")
    t = Tumblpy(CONSUMER_KEY, CONSUMER_SECRET)

    auth_props = t.get_authentication_tokens()
    auth_url = auth_props['auth_url']

    token = auth_props['oauth_token']
    token_secret = auth_props['oauth_token_secret']

    print("auth_url: ", auth_url)
    print("token: ", token)
    print("token_secret: ", token_secret)


# https://www.tumblr.com/docs/en/api/v2#tagged-method
# https://github.com/michaelhelmick/python-tumblpy
# http://inmyzakki.hatenablog.com/entry/2017/05/08/231308


def download_images_from_tumblr(tag,
                                max_count=10,
                                before_timestamp=None,
                                saved_path=None,
                                is_face_detect=None,
                                is_animeface=None):
    print("download_image_from_tumblr/tag:", tag, ", before_timestamp:", before_timestamp)

    dl_count = 0
    fc_count = 0
    last_timestamp = 0

    t = Tumblpy(CONSUMER_KEY, CONSUMER_SECRET,
                OAUTH_TOKEN, OAUTH_TOKEN_SECRET)

    params = {'tag': tag}
    if before_timestamp is not None:
        params.update({"timestamp": before_timestamp})

    output_path = saved_path
    if saved_path is None:
        output_path = "./dl_tumblr/" + tag

    while dl_count < max_count:

        if last_timestamp > 0:
            params.update({"before": last_timestamp})

        tags = None
        try:
            tags = t.get('tagged', params=params)
        except Exception as e:
            print("error: ", str(e))
        # print("tags: ", tags)

        if tags == None or len(tags) == 0:
            print("end: tags is void")
            break

        for i, tag in enumerate(tags):

            if i == None or tag == None:
                break

            # print("index: ", i, ", tag: ", tag)
            last_timestamp = tag["timestamp"]

            if "photos" in tag:
                photos = tag["photos"]
                for j, photo in enumerate(photos):
                    # print("index: ", j, ", tag: ", photo)
                    image_url = photo["original_size"]["url"]
                    # print("i:", i, "j:", j, ", image_url:", image_url)
                    file_path = download_image(image_url, output_path)
                    if file_path:
                        dl_count += 1
                        if is_face_detect is not None:
                            fc_count += save_detected_faces(image_path=file_path, is_animeface=is_animeface)
            else:
                break

    return dl_count, fc_count, last_timestamp


def main():
    print("main")

    # tag = "有村架純"
    # is_animeface = False

    # tag = "涼風青葉" # tag = "aoba suzukaze"
    # tag = "滝本ひふみ" # tag = "hifumi takimoto"
    # tag = "八神コウ" # tag = "kou yagami"
    #tag = "篠田はじめ" # tag = "hajime shinoda"
    #tag = "飯島ゆん" # tag = "yun iijima"
    # tag = "桜ねね" tag = "nene sakura"
    # tag = "阿波根うみこ" # tag = "umiko ahagon"
    # tag = "遠山りん" # tag = "rin tooyama"
    # tag = "葉月しずく" #tag = "shizuku hazuki"

    # 志摩リン（しまリン

    tag = "志摩リン"
    tag = "shima rin"
    tag = "各務原なでしこ"
    tag = "kagamihara nadeshiko"
    tag = "斉藤恵那"
    tag = "saitou ena"
    tag = "大垣千明"
    tag = "oogaki chiaki"
    tag = "犬山あおい"
    tag = "inuyama aoi"

    is_animeface = True

    max_count = 100
    timestamp = None

    calc_time = time.time()  # 開始時間
    dl_count, fc_count, timestamp = download_images_from_tumblr(tag=tag,
                                                                max_count=max_count,
                                                                before_timestamp=timestamp,
                                                                is_face_detect=True,
                                                                is_animeface=is_animeface)
    calc_time = time.time() - calc_time
    print("dl_count:", dl_count, ", fc_count", fc_count, ", timestamp:", timestamp, ", calc_time:", calc_time, "sec")


if __name__ == "__main__":
    # execute only if run as a script
    main()
