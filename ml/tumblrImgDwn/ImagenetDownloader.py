import random
import os.path
import urllib
import urllib.request
import hashlib

def download_images_from_imageset(image_class=1000, pictures=100, saved_path=None):
    print("download_images_from_imageset/", image_class, pictures, saved_path)

    dict = {}
    for line in open('./imagenet/words.txt', 'r'):
        line2 = line.split()
        cat_name = ""
        for i, tmp_line in enumerate(line2):
            if i > 0:
                cat_name = cat_name + tmp_line
        cat_name = cat_name.replace(",", "-")
        dict[line2[0]] = cat_name
    # print("dict:", dict)

    ids = open('./imagenet/imagenet.synset.obtain_synset_list', 'r').read()
    ids = ids.split()
    random.shuffle(ids)
    # print("ids:", ids)

    if image_class > len(ids):
        image_class = len(ids) - 1

    output_path = saved_path
    if saved_path is None:
        output_path = "./dl_imagenet"
    os.makedirs(output_path, exist_ok=True)

    cat_count = 0
    for row_id in ids:
        cat_id = row_id.rstrip()
        category = dict[cat_id]
        dl_count = 0

        category_path = os.path.join(output_path, category)
        os.makedirs(category_path, exist_ok=True)
        print("cat_count:", cat_count, ", category:", category)

        try:
            urls = urllib.request.urlopen(
                "http://www.image-net.org/api/text/imagenet.synset.geturls?wnid=" + cat_id).read()
            urls = urls.split()
            random.shuffle(urls)
            # print("urls:", urls)
            print("len(urls):", len(urls))

            for row_url in urls:
                url = row_url.decode('utf-8')
                print("cat_count:", cat_count, ", dl_count:", dl_count, ", url:", url)
                image_name, ext = os.path.splitext(url)

                # このtryがないと，ダウンロードのときの例外時に同カテゴリーの再ダウンロードが始まらない
                try:
                    # ファイル名が規則性がなく，上書きされないように，urlでハッシュ化しておく
                    hashed_file_name = hashlib.sha1(url.encode('utf-8')).hexdigest()
                    filename = hashed_file_name + ".jpg"
                    if ".png" in ext:
                        filename = hashed_file_name + ".png"
                    elif ".gif" in ext:
                        filename = hashed_file_name + ".gif"
                    filename = str(dl_count) + "_" + filename
                    # print("filename:", filename)
                    output = os.path.join(category_path, filename)
                    # print("output:", output)

                    try:
                        if os.path.exists(output):
                            print("this image was already downloaded")
                        else:
                            any_url_obj = urllib.request.urlopen(url, timeout=30)
                            local = open(output, 'wb')
                            local.write(any_url_obj.read())
                            any_url_obj.close()
                            local.close()

                        size = os.path.getsize(output)
                        if size == 2051:  # flickr Error
                            os.remove(output)
                            dl_count -= 1

                        dl_count += 1
                    except Exception as e:
                        print("error2: ", str(e))
                        os.remove(output)

                    if dl_count >= pictures or len(urls) <= dl_count:
                        break

                except Exception as e:
                    print("error1: ", str(e))


            cat_count += 1
        except Exception as e:
            print("error0: ", str(e))
            continue

        if cat_count >= image_class:
            break

    print("download_images_from_imageset/end")


if __name__ == "__main__":
    print("main")

    download_images_from_imageset(image_class=5, pictures=1000)
