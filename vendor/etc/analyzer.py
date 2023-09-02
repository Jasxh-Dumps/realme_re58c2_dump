#!/usr/bin/env python
# -*- coding:utf-8 -*-
"""
Copyright (C) 2019 Unisoc
Created on Jan 18, 2016
2016.03.11 -- add ytag parser
2019.01.05 -- add .ylog parser
2019.11.19 -- add ylog 4.x cap file parser
"""

import errno
import operator
import optparse
import os
import shutil
import sys
import traceback
import zlib
from ctypes import *

LOG_FILE_MAX_SIZE = 1024 * 1024 * 250
KEY_LENGTH = 1


class FileHeader(Structure):
    _fields_ = [('m', c_int),
                ('r', c_char * 64),
                ('v', c_int),
                ('re', c_char * 24), ]


class BlockHeader(Structure):
    _fields_ = [('m', c_int),
                ('seq', c_uint),
                ('l', c_int),
                ('z', c_int),
                ('t', c_char)]


class FileTail(Structure):
    _fields_ = [('m', c_int),
                ('seq', c_uint),
                ('l', c_int),
                ('v', c_int),
                ('r', c_char * 64),
                ('re', c_char * 24), ]


ANDROID_LOG_FILE_DICT = {
    'M': 'android_main.log',
    'S': 'android_system.log',
    'R': 'android_radio.log',
    'E': 'android_events.log',
    'C': 'android_crash.log',
}
YLOG_LOG_FILE_DICT = {}
YLOG_CTL_CMD_DICT = {}
YLOG_LOG_FILE_FD_DICT = {}
YLOG_LOG_FILE_ID_DICT = {}

IS_DEBUG_MODE = False

# Python version check
ver = sys.version_info
if ver[0] == 3:
    my_open = open
else:
    def my_open(file, mode='rb'):
        return open(file, mode)


def get_next_filename(old_file_name, index):
    return "{id}-{name}".format(id=index, name=old_file_name)


def split_andorid_log_file(root_dir, log_file_dir_path, android_log, android_log_file_dict):
    android_log_file_fd_dict = {}
    android_log_file_id_dict = {}
    keys = list(android_log_file_dict.keys())
    last_token = ''
    log_file_dir_full_path = root_dir + log_file_dir_path

    for key in keys:
        android_log_file_id_dict[key] = 0
        filename = get_next_filename(android_log_file_dict[key], android_log_file_id_dict[key])
        android_log_file_fd_dict[key] = my_open(os.path.join(log_file_dir_full_path, filename), 'wb')

    count = -1
    while True:
        count = count + 1
        filename = os.path.join(log_file_dir_full_path, get_next_filename(android_log, count))
        log_file = None
        if os.path.isfile(filename):
            log_file = my_open(filename, 'rb')
        if log_file is None:
            break
        for binary_data in log_file.readlines():
            log_line = binary_data.decode(errors='ignore')
            if log_line[0:KEY_LENGTH] in keys:
                token = log_line[0:KEY_LENGTH]
                android_log_file_fd_dict[token].write(binary_data)
                last_token = token
                if android_log_file_fd_dict[token].tell() > LOG_FILE_MAX_SIZE:
                    android_log_file_id_dict[token] = android_log_file_id_dict[token] + 1
                    filename = get_next_filename(android_log_file_dict[token], android_log_file_id_dict[token])
                    android_log_file_fd_dict[token].close()
                    android_log_file_fd_dict[token] = my_open(os.path.join(log_file_dir_full_path, filename), 'wb')
            else:
                if len(last_token) > 0:
                    android_log_file_fd_dict[last_token].write(binary_data)
        log_file.close()

    for key in keys:
        android_log_file_fd_dict[key].close()


def unzip_ylog_file(ylog_file, log_file_dir):
    global IS_DEBUG_MODE
    ylog_dict_build = False
    debug_log_file = None
    try:
        tmp_ylog_file = ylog_file + ".tmp"
        if not os.path.isfile(ylog_file):
            print("open ylog err")
            return
        if IS_DEBUG_MODE:
            debug_log_file = open(tmp_ylog_file, "wb")

        with open(ylog_file, 'rb') as file:
            file_header = FileHeader()
            while file.readinto(file_header) == sizeof(file_header):
                if file_header.m != 0x2E2E:
                    if IS_DEBUG_MODE:
                        print('format error')
                    pass
                break

            block_header = BlockHeader()
            block_count = 1

            block_size = sizeof(BlockHeader)
            read_block_size = file.readinto(block_header)
            seeking = False

            while read_block_size == block_size:
                block_count = block_count + 1
                if block_header.m != 0x5A5A:
                    if block_header.m == 0xB5B5:
                        file.read(sizeof(FileTail) - sizeof(BlockHeader))
                    else:
                        if block_header.m == 0x2E2E:
                            file.read(sizeof(FileHeader) - sizeof(BlockHeader))
                        else:
                            file.seek(1 - read_block_size, 1)
                            seeking = True
                else:
                    if seeking:
                        if (block_header.seq > 0) and (block_header.l > 0) and (block_header.z == 0 or block_header.z == 1):
                            if IS_DEBUG_MODE:
                                print("seek done! position ", file.tell() - block_size)
                            seeking = False
                        else:
                            read_block_size = file.readinto(block_header)
                            continue
                    block_data = file.read(block_header.l)
                    if block_header.z == 1:
                        try:
                            raw_data = zlib.decompress(block_data)
                        except:
                            pass
                    else:
                        raw_data = block_data

                    if not ylog_dict_build:
                        ylog_dict_build = True
                        build_ylog_dict(raw_data, log_file_dir)

                    if (block_header.t != '\x00') and (ord(block_header.t) != 0):
                        key_order = ord(block_header.t)

                        if YLOG_CTL_CMD_DICT[key_order] == 0:
                            decode_data = raw_data.decode(errors='ignore')
                            if decode_data.find('YZIPC') != -1 and decode_data.find('CPIZY') != -1:
                                YLOG_CTL_CMD_DICT[key_order] = 1

                        YLOG_LOG_FILE_FD_DICT[key_order].write(raw_data)

                        if (YLOG_LOG_FILE_FD_DICT[key_order].tell() > LOG_FILE_MAX_SIZE) and (
                                YLOG_LOG_FILE_ID_DICT[key_order] != -1):
                            YLOG_LOG_FILE_ID_DICT[key_order] = YLOG_LOG_FILE_ID_DICT[key_order] + 1
                            filename = get_next_filename(YLOG_LOG_FILE_DICT[key_order],
                                                         YLOG_LOG_FILE_ID_DICT[key_order])
                            YLOG_LOG_FILE_FD_DICT[key_order].close()
                            YLOG_LOG_FILE_FD_DICT[key_order] = my_open(
                                os.path.join(log_file_dir, filename), 'wb')
                            YLOG_LOG_FILE_FD_DICT[key_order].write(raw_data[raw_data.rfind("\n".encode())+1:])

                    if IS_DEBUG_MODE:
                        debug_log_file.write(raw_data)
                read_block_size = file.readinto(block_header)
    except:
        traceback.print_exc()
        pass
    if debug_log_file is not None:
        debug_log_file.close()

    keys = list(YLOG_LOG_FILE_FD_DICT.keys())
    for key in keys:
        if YLOG_LOG_FILE_FD_DICT[key] is not None:
            YLOG_LOG_FILE_FD_DICT[key].close()


def build_ylog_dict(meta_info, log_file_dir):
    YLOG_LOG_FILE_DICT.clear()
    YLOG_CTL_CMD_DICT.clear()
    if IS_DEBUG_MODE:
        print(YLOG_LOG_FILE_DICT)
        print('meta:', meta_info)
    meta = meta_info.decode("utf-8")
    start = meta.find("TAGS:")
    line = meta[start:]
    if line[0:5] == "TAGS:":
        if IS_DEBUG_MODE:
            print(line)
        line.strip()
        tags = [x for x in line[5:256].split(';') if x.strip()]
        for tag in tags:
            key = tag[0:tag.find(":")]
            value = tag[tag.find(":") + 1:]
            key_order = ord(key)
            YLOG_LOG_FILE_DICT.update({key_order: value})
            YLOG_CTL_CMD_DICT.update({key_order: 0})

    if IS_DEBUG_MODE:
        print('all log dict:', YLOG_LOG_FILE_DICT.keys())

    keys = list(YLOG_LOG_FILE_DICT.keys())
    for key in keys:
        YLOG_LOG_FILE_ID_DICT[key] = 0
        if YLOG_LOG_FILE_DICT[key].find('.log') == -1:
            YLOG_LOG_FILE_ID_DICT[key] = -1
        filename = YLOG_LOG_FILE_DICT[key]
        if YLOG_LOG_FILE_ID_DICT[key] != -1:
            filename = get_next_filename(filename, YLOG_LOG_FILE_ID_DICT[key])
        YLOG_LOG_FILE_FD_DICT[key] = my_open(os.path.join(log_file_dir, filename), 'wb')
        if IS_DEBUG_MODE:
            print("new fd dict:", key, '=', YLOG_LOG_FILE_FD_DICT[key])


def repair_cap_file(filename, filemagic):
    if ver[0] == 3:
        magic = filemagic
    else:
        magic = str(filemagic)

    raw_cap_file = open(filename, "rb")

    while True:
        data = raw_cap_file.read(len(magic))
        if len(data) < len(magic):
            if IS_DEBUG_MODE:
                print(filename, "repair failed....")
            break
        if operator.eq(data, magic):
            if raw_cap_file.tell() == len(magic):
                if IS_DEBUG_MODE:
                    print(filename, "raw format ok....")
                break
            if raw_cap_file.tell() > 0:
                tmp_file_name = filename + '.tmp'
                tmp_file_fd = open(tmp_file_name, 'wb')
                raw_cap_file.seek(-1 * len(magic), 1)
                tmp_file_fd.write(raw_cap_file.read())
                tmp_file_fd.close()
                raw_cap_file.close()
                if IS_DEBUG_MODE:
                    print(filename, "repair ok....")
                    print(tmp_file_name, filename)
                os.remove(filename)
                os.rename(tmp_file_name, filename)
            return True
        raw_cap_file.seek(-1 * (len(magic) - 1), 1)
    raw_cap_file.close()


def parser_ylog_files(root_path, ylog_files):
    for file in ylog_files:
        log_file_dir_path = file.replace('.ylog', '')
        log_file_dir = log_file_dir_path
        log_file_dir_path = '.' + os.sep + log_file_dir_path
        print('extracting  ' + file + ' to ' + log_file_dir + os.sep)

        if os.path.exists(log_file_dir_path):
            shutil.rmtree(log_file_dir_path)
        try:
            os.mkdir(log_file_dir_path)
        except:
            if IS_DEBUG_MODE:
                traceback.print_exc()
            pass

        unzip_ylog_file(file, log_file_dir_path)

        try:
            split_andorid_log_file(root_path, log_file_dir_path, "android.log", ANDROID_LOG_FILE_DICT)
            parser_ctl_cmd(log_file_dir_path)
        except:
            if IS_DEBUG_MODE:
                traceback.print_exc()
            pass

        recheck_file(log_file_dir_path)
        continue


def recheck_file(log_file_dir_path):
    out_log_files = os.listdir(log_file_dir_path)
    for out_log_file in out_log_files:
        log_file = os.path.join(log_file_dir_path, out_log_file)
        if (not os.path.isdir(log_file)) and (0 == os.path.getsize(log_file)):
            os.remove(log_file)
            continue
        if not os.path.isdir(log_file):
            if 'tcpdump' in log_file:
                repair_cap_file(log_file, b'\xd4\xc3\xb2\xa1')
            if 'hcidump' in log_file:
                repair_cap_file(log_file, b'\x62\x74\x73\x6e\x6f\x6f\x70')


def parser_ctl_cmd(log_file_dir):
    keys = list(YLOG_LOG_FILE_DICT.keys())
    for key in keys:
        if YLOG_CTL_CMD_DICT[key] != 1:
            continue
        filename = YLOG_LOG_FILE_DICT[key]
        log_file_name = os.path.join(log_file_dir, '0-' + filename)
        yzipctl_cmd_len = 40
        if ('lastlog' in log_file_name) and (os.path.getsize(log_file_name) < yzipctl_cmd_len):
            os.remove(log_file_name)
            continue
        log_file_fd = my_open(log_file_name, 'rb')
        out_file_fd = None
        for binary_data in log_file_fd.readlines():
            line_data = binary_data.decode(errors='ignore')
            start = line_data.find('YZIPC02')
            if start != -1:
                end = line_data.find('20CPIZY')
                out_file_name = log_file_dir + os.sep + binary_data[start + 7:end].decode(errors='ignore')
                if out_file_fd is not None:
                    out_file_fd.write(binary_data[0:start])
                    out_file_fd.close()
                if not os.path.exists(os.path.dirname(out_file_name)):
                    try:
                        os.makedirs(os.path.dirname(out_file_name))
                    except OSError as exc:
                        if exc.errno != errno.EEXIST:
                            raise
                out_file_fd = my_open(out_file_name, 'wb')
                out_file_fd.write(binary_data[end + 7:])
            else:
                if out_file_fd is not None:
                    out_file_fd.write(binary_data)
        log_file_fd.close()
        out_file_fd.close()


def static_andorid_log(android_log_file):
    is_first_line = None
    last_line = ""
    line_count = 0
    liblog_count = 0
    lost_log_count = 0
    word_dict = {}
    is_ylog_log = None
    with my_open(android_log_file, 'rb') as f:
        for binary_line in f.readlines():
            if is_first_line is None:
                is_first_line = binary_line
            last_line = binary_line
            line_count = line_count + 1
            line = binary_line.decode(errors='ignore')
            if line.find('liblog  :') > 0:
                liblog_count = liblog_count + 1
                liblog_value = line[line.find('liblog  :') + 9:]
                if IS_DEBUG_MODE:
                    print(int(liblog_value))
                lost_log_count = lost_log_count + int(liblog_value)
            else:
                keys = line.split()
                if len(keys) > 6:
                    if '---' in keys[0]:
                        continue
                    if is_ylog_log is None:
                        if ('M' in keys[0] or 'S' in keys[0] or 'E' in keys[0] or 'R' in keys[0] or 'C' in keys[0]):
                            is_ylog_log = True
                        else:
                            is_ylog_log = False
                    if is_ylog_log:
                        tag_index = 6
                    else:
                        tag_index = 5
                    key = keys[tag_index]
                else:
                    key = "unknown"
                if key in word_dict:
                    word_dict[key] += 1
                else:
                    word_dict[key] = 1

        word_tups = sorted(word_dict.items(), key=lambda x: x[1], reverse=True)

        if IS_DEBUG_MODE:
            print('0:', is_first_line)
            print(line_count, ':', last_line)
            print('liblog', liblog_count)
            print('liblogc', lost_log_count)

        print('Android log output statistics ')
        ljust_len = 18
        print('Lost rate : '.ljust(ljust_len) + '{:.2%}'.format(
            lost_log_count * 1.0001 / (line_count + lost_log_count) * 1.0001))
        print("Total line num:".ljust(ljust_len) + str(line_count + lost_log_count))
        print("Lost  line num:".ljust(ljust_len) + str(lost_log_count))
        print('\n')

        max_tags = 0
        print('Chattiest top 12 tags:')
        print('TAG'.ljust(32) + 'NUM'.ljust(8) + 'PERCENT')
        for word_tup in word_tups:
            max_tags += 1
            print(
                word_tup[0].ljust(32) + str(word_tup[1]).ljust(8) + '{:.2%}'.format(word_tup[1] * 1.0001 / line_count))
            if max_tags > 12:
                break

    print('\n')


def sort_by_apk_path(elem):
    return elem[2]


def get_version_info(log_file):
    lst = []
    version_info_file = log_file + '.version.log'

    outfile = open(version_info_file, 'w')

    do_dump_package = None
    package_name = None
    apk_path = None

    with my_open(log_file, 'rb') as f:
        for binary_line in f.readlines():
            line = binary_line.decode(errors='ignore')
            if 'dumpsys package' in line:
                last_do_dump_package = do_dump_package
                do_dump_package = line
                if last_do_dump_package is not None:
                    lst.sort(key=sort_by_apk_path)
                    outfile.write('\n\n' + last_do_dump_package)
                    for i in lst:
                        outfile.write(i[0] + ' ' + i[1] + ' ' + i[2] + '\n')
                    lst = []
                    package_name = None
                    apk_path = None
            else:
                if package_name is None:
                    if 'Package [' in line:
                        package_name = line
                else:
                    if apk_path is None:
                        if 'codePath=' in line:
                            apk_path = line
                    else:
                        if 'versionName=' in line:
                            version_info = line
                            lst.append((package_name.strip(), version_info.strip(), apk_path.strip()))
                            package_name = None
                            apk_path = None

    if do_dump_package is not None:
        lst.sort(key=sort_by_apk_path)
        outfile.write('\n\n' + do_dump_package)
        for i in lst:
            outfile.write(i[0] + ' ' + i[1] + ' ' + i[2] + '\n')

    outfile.close()
    print('get version info to  file ' + version_info_file)


def main():
    global IS_DEBUG_MODE

    os.chdir(os.path.dirname(os.path.abspath(sys.argv[0])))
    ylog_parser_relative_path = '.' + os.sep
    parser = optparse.OptionParser()
    parser.add_option('-d', dest='set_debug_mode', default=False, action='store_true', help='output some debug info')
    parser.add_option('-s', dest='do_statis', default=False, action='store_true', help='statistics  log file')
    parser.add_option('-v', dest='do_versioninfo', default=False, action='store_true', help='get apk version   file')
    options, args = parser.parse_args()

    if options.set_debug_mode:
        IS_DEBUG_MODE = True

    if options.do_statis:
        static_andorid_log(ylog_parser_relative_path + sys.argv[2])
        return

    if options.do_versioninfo:
        get_version_info(ylog_parser_relative_path + sys.argv[2])
        return

    if not args:
        all_files = os.listdir(os.path.join(ylog_parser_relative_path, ''))
        if IS_DEBUG_MODE:
            print(all_files)
        ylog_files = [f for f in all_files if f.find(".ylog", len(f) - 5) > 1]
    else:
        ylog_files = args

    if IS_DEBUG_MODE:
        print(ylog_files)

    parser_ylog_files(ylog_parser_relative_path, ylog_files)

    print("extract done")


if __name__ == '__main__':
    main()
