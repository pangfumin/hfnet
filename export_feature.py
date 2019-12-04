import sys

import time
import numpy as np
import sys,os
import cv2
from pathlib import Path
import matplotlib.pyplot as plt
from hfnet.settings import EXPER_PATH
from notebooks.utils import plot_images, plot_matches, add_frame

import tensorflow as tf
from tensorflow.python.saved_model import tag_constants
import logging
from tqdm import tqdm
import numpy as np
from scipy.spatial.transform import Rotation as R, Slerp 
from numpy.linalg import inv, norm
logging.basicConfig(format='[%(asctime)s %(levelname)s] %(message)s',
                    datefmt='%m/%d/%Y %H:%M:%S',
                    level=logging.INFO)
from hfnet.datasets import get_dataset  # noqa: E402
from hfnet.evaluation.loaders import export_loader  # noqa: E402
from hfnet.settings import EXPER_PATH  # noqa: E402
from scipy import spatial


tf.contrib.resampler  # import C++ op
class HFNet:
    def __init__(self, model_path, outputs):
        self.session = tf.Session()
        self.image_ph = tf.placeholder(tf.float32, shape=(None, None, 3))

        net_input = tf.image.rgb_to_grayscale(self.image_ph[None])
        tf.saved_model.loader.load(
            self.session, [tag_constants.SERVING], str(model_path),
            clear_devices=True,
            input_map={'image:0': net_input})

        graph = tf.get_default_graph()
        self.outputs = {n: graph.get_tensor_by_name(n+':0')[0] for n in outputs}
        self.nms_radius_op = graph.get_tensor_by_name('pred/simple_nms/radius:0')
        self.num_keypoints_op = graph.get_tensor_by_name('pred/top_k_keypoints/k:0')
    def inference(self, image, nms_radius=4, num_keypoints=1000):
        inputs = {
            self.image_ph: image[..., ::-1].astype(np.float),
            self.nms_radius_op: nms_radius,
            self.num_keypoints_op: num_keypoints,
        }
        return self.session.run(self.outputs, feed_dict=inputs)

model_path = Path(EXPER_PATH, 'saved_models/hfnet')
outputs = ['global_descriptor', 'keypoints', 'local_descriptors','scores']
hfnet = HFNet(model_path, outputs)

# %load_ext autoreload
# %autoreload 2
db_path =  "/media/pang/Elements1/dataset/south-building/images/"
export_path = '/media/pang/Elements1/dataset/south-building/hf_feature_new/'
image_file_ext = "JPG"

db_list = os.listdir(db_path)
db_list.sort()


## export feature for SfM

if not os.path.isdir(export_path):
    os.mkdir(export_path)


for i in range(len(db_list)):
    image_file = db_path + db_list[i]
    if image_file[-3:] == image_file_ext:
        print (image_file)
        image = cv2.imread(image_file)[:, :, ::-1]
        print(type(image))
        data = hfnet.inference(image)
        export = {
            'keypoints': data['keypoints'],
            'local_descriptors': data['local_descriptors'],
            'global_descriptor':data['global_descriptor'],
            'scores':data['scores']
        }
        name = export_path + db_list[i][:-4]
        np.savez(f'{name}.npz', **export)