import argparse
import numpy as np
import os
import sqlite3

from internal.nvm_to_colmap_helper import convert_nvm_pose_to_colmap_p
from internal.db_handling import blob_to_array


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--model_folder', required=True)
    args = parser.parse_args()
    return args




def main():
    args = parse_args()
    camera_txt = args.model_folder + "/cameras.txt"
    point3d_txt = args.model_folder + "/points3D.txt"
    image_txt = args.model_folder + "/images.txt"

    temp_camera_txt = args.model_folder + "/tem_cameras.txt"
    temp_image_txt = args.model_folder + "/tem_images.txt"

    print(camera_txt)
    print(point3d_txt)
    print(image_txt)

    # 1. remove point3d txt
    # if os.path.exists(point3d_txt):
    #     os.remove(point3d_txt)
    # else:
    #     print("Can not delete the file as it doesn't exists")

    # 2. re-write camera txt
    with open(camera_txt, "r") as f:
        lines = f.readlines()
    with open(temp_camera_txt, "w") as f:
        for line in lines:
            if line.startswith("#") or line.startswith("1"):
                print(line)
                f.write(line)

    # 3. clear images txt
    with open(image_txt, "r") as f:
        lines = f.readlines()
    with open(temp_image_txt, "w") as f:
        already_skip_header = False
        for line in lines:
            if line.startswith("#"):
                print(line)
                f.write(line)
            if "JPG" in line:
                already_skip_header = True
                # re-write camera model
                token = line.split();
                print(token)
                print(line)
                token[8] = "1"
                listToStr = ' '.join([str(elem) for elem in token]) 
                listToStr = listToStr + "\n"
                f.write(listToStr)
            elif(already_skip_header):
                f.write("\n")



    


if __name__ == '__main__':
    main()