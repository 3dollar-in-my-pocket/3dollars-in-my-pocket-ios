#-*- coding=utf-8 -*-

import os
import sys
import urllib
import csv
from imp import reload
from urllib.request import urlretrieve

reload(sys)

gdoc_id = "1Af6kiSYN-uPgxGfHZSewH6lzHsXtHZsZeDuclEYUC60/edit#gid=0"


def get_gdoc_information():
    download_path = sys.argv[1]
    try:
        csv_file = export_csv_from_sheet(gdoc_id)
        string_list = get_strings_from_csv(download_path, csv_file)
        write_strings(string_list, download_path)
    except Exception as e:
        print(":::::::::::::ERROR:::::::::::::")
        print(e)


def export_csv_from_sheet(gdoc_id, download_path=None, ):
    print("Downloading the CVS file with id %s" % gdoc_id)

    resource = gdoc_id.split('/')[0]
    tab = gdoc_id.split('#')[1].split('=')[1]
    resource_id = 'spreadsheet:' + resource

    if download_path is None:
        download_path = os.path.abspath(os.path.dirname(__file__))

    file_name = os.path.join(download_path, '%s.csv' % (resource))

    print('download_path : %s' % download_path)
    print('Downloading spreadsheet to %s' % file_name)

    url = 'https://docs.google.com/spreadsheet/ccc?key=%s&output=csv&gid=%s' % (resource, tab)
    urlretrieve(url, file_name)

    print("Download Completed!")

    return file_name


def get_strings_from_csv(savepath, file_name):
    print("read CSV file : %s" % file_name)

    source_csv = open(file_name, "r")
    csv_reader = csv.reader(source_csv)
    header = csv_reader.__next__()
    index_key = header.index("key")
    index_ko = header.index("ko")

    string_list = []

    # Loop through the lines in the file and get each coordinate
    for row in csv_reader:
        key = row[index_key]
        ko = row[index_ko]

        dict_string = {
            "key": key,
            "ko": ko
        }
        string_list.append(dict_string)

    source_csv.close()
    os.remove(file_name)

    return string_list


def write_strings(string_list, save_path):
    if not os.path.exists(save_path + "/resource/en.lproj/"):
        os.makedirs(save_path + "/resource/en.lproj/")

    string_file = open(save_path + "/resource/en.lproj/Localization.strings", "w")

    for item in string_list:
        string_file.write("\"" + item["key"] + "\" = \"" + item["ko"] + "\";\n")

    string_file.close()


if __name__ == '__main__':
    get_gdoc_information()
