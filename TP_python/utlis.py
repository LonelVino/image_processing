from pathlib import Path
import cv2
import os
import matplotlib.pyplot as plt
import numpy as np
import pickle
import math
import random
from tqdm import tqdm


# load reference images
def load_dir_images(dir_name, img_type, grayscale=False):
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
    for filename in Path(dir_name).glob('*.'+img_type):
        img = cv2.imread(str(filename))
        if grayscale:
            img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        img_dict[str(filename)] = img
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

def save_dict(dict_, path):
    a_file = open(path, "wb")
    pickle.dump(dict_, a_file)
    
    
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
