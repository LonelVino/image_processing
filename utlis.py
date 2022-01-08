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


def disp_multi_images(images, labels=None, suptitle=''):
    ''' Visualize images    
    Args:
        images (np.darray): the  images
    '''
    len_images = len(images) if len(images)<=25 else 25
    num = math.ceil(math.sqrt(len_images))
    idxs = random.sample(range(0, len(images)), len_images)
    
    fig = plt.figure(figsize=(num**2,num**2)) if num > 3 else  plt.figure(figsize=((num+1)**2,(num+1)**2))
    plt.suptitle("Images " + suptitle,  size=16, y=3)
    
    for count, index in enumerate(idxs):
        ax = fig.add_subplot(num, num, count + 1, xticks=[], yticks=[])
        image = images[index]
        ax.imshow(image, cmap='gray')
        if labels is not None:
            ax.set_title('Class {%s}'%labels[index])
        
        if count==len_images-1:
            plt.show()
            break    


def view_dir_images(dir_name='appr', type_image_train='png'):
    img_train_dict = load_dir_images(dir_name = './'+dir_name, img_type=type_image_train)
    img_train_names = list(img_train_dict.keys())
    labels_file = open("./{:s}/labels.pkl".format(dir_name), "rb")
    labels = pickle.load(labels_file)

    np.random.seed(19680801)
    fig, ax = plt.subplots()

    for i in range(len(img_train_dict)):
        ax.cla()
        filename = img_train_names[i]
        ax.imshow(img_train_dict[filename])
        ax.set_title("Path: {:s};  Class: {:d}".format(filename, labels['./' + filename]))
        # Note that using time.sleep does *not* work here!
        plt.pause(0.3)


def display_mis_images(target_test, y_val_pred, filenames_test, images_test_og, target_test_og, filenames_test_og):
    mis_idxs = [idx for (idx, label) in enumerate(target_test) if (label != y_val_pred[idx])]
    mis_labels = y_val_pred[mis_idxs]
    mis_filenames = filenames_test[mis_idxs]
    print('Number of MISCLASSIFIED images', len(mis_filenames))
    mis_idxs_og = [list(filenames_test_og).index(filename) for (idx, filename) in enumerate(mis_filenames)]
    mis_images = [images_test_og[idx] for idx in mis_idxs_og]
    labels_map = dict(zip(list(range(1,7)), \
                ['circle', 'rect', 'ellipse', 'star', 'H', 'Y']))
    mis_true_labels = [labels_map[target_test_og[idx]] for idx in mis_idxs_og]
    len_images = len(mis_images) if len(mis_images)<=25 else 25
    num = math.ceil(math.sqrt(len_images))
    idxs = random.sample(range(0, len(mis_images)), len_images)
    
    fig = plt.figure(figsize=(num**2,num**2)) if num > 3 else  plt.figure(figsize=((num+1)**2,(num+1)**2))
    plt.title("Misclassified images (True Label - Predicted Label)",  fontsize=16)
    plt.subplots_adjust(bottom=0.2)
    for count, index in enumerate(idxs):
        ax = fig.add_subplot(num, num, count + 1, xticks=[], yticks=[])
        image = mis_images[count]
        ax.set_title('True Label: {:s}\n Predict Label: {:s}'.\
            format(mis_true_labels[count], labels_map[mis_labels[count]]),
                    fontsize=12)
        ax.imshow(image)

        if count==len_images-1:
            break