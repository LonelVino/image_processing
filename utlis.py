from pathlib import Path
import cv2
import os
import matplotlib.pyplot as plt
import numpy as np
import pickle
import math
import random
from tqdm import tqdm
from argparse import ArgumentTypeError


plt.rc('font', family='serif')
plt.rc('xtick', labelsize='x-large')
plt.rc('ytick', labelsize='x-large')
plt.rc('axes', labelsize='x-large', titlesize='x-large')


def str2bool(v):
    if isinstance(v, bool):
        return v
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise ArgumentTypeError('Boolean value expected.')


# load reference images
def load_dir_images(dir_name, img_type, grayscale=False, N=None):
    '''
    Load all images in a folder
    
    Parameters
    -------------
    dir_name (str): the name of the root directory (absolute or relative path)
    img_type (str): the type of the target image， i.e. the File Suffix
    
    Returns
    -------------
    img_dict (dict): all images in the target folder (key: filename, value: image (ndarray))
    '''
    img_dict = {}
    idx = 0
    for filename in Path(dir_name).glob('*.'+img_type):
        img = cv2.imread(str(filename))
        if grayscale:
            img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        img_dict[str(filename)] = img
        idx += 1
        if N is not None:
            if idx >= N: break
    return img_dict


def save_images(images, dir_name, base_names, img_type='png', clear_cache=False):
    CHECK_FOLDER = os.path.isdir(dir_name)
    # If folder doesn't exist, then create it.
    if not CHECK_FOLDER:
        os.makedirs(dir_name)
    elif clear_cache is True:
        # delete all images
        for f in Path(dir_name).glob("*.*"):
            os.remove(f)
            
    # Save images in target directory    
    for idx, img in tqdm(enumerate(images)):
        file_path = os.path.join(dir_name + base_names[idx][:-4] + '.' + img_type)
        cv2.imwrite(file_path, img.astype(np.uint8))
        
def save_dict(dict_, path):
    a_file = open(path, "wb")
    pickle.dump(dict_, a_file)

