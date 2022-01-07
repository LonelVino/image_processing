from pathlib import Path
import random
import os
import pickle
import cv2
from tqdm import tqdm

from image_process import image_random_transform
from dataset import load_dataset
from utlis import load_dir_images

def gene_train_images(ref='reference', train='appr/origin', type_image_ref='bmp', type_image_train='png', N=100):
    '''
    Generate N training images based on all the reference images by selecting randomly
    Generate a TXT file recording labels related to each image file name 
    
    Args:
    -------------------------
        ref (str): Name of the directory containing the initial forms
        base (str): Name of the directory storing the initial forms
        type_image_ref (str): type des images de reference
        type_image_base (str): type des images generees dans la base
        N (int): nombre d'images generees
    '''
    CHECK_FOLDER = os.path.isdir(train)
    # If folder doesn't exist, then create it.
    if not CHECK_FOLDER:
        print('[INFO] FOLDER NOT EXIST, CREATING A NEW ONE...')
        os.makedirs(train)
    else:
        # delete all images
        for f in Path(train).glob("*.*"):
            os.remove(f)
    
    # load reference images
    img_ref_dict = load_dir_images(dir_name = ref, img_type=type_image_ref)
    img_ref_names = list(img_ref_dict.keys())
    
    # Generate N training images based on all the reference images by selecting randomly
    labels = {}
    images = {}
    for i in tqdm(range(N)):
        ref_filename = random.choice(img_ref_names)
        image = cv2.imread(ref_filename, cv2.IMREAD_GRAYSCALE)
        image_transformed = image_random_transform(image)
        key = 'mesure{:04d}.{:s}'.format(i+1, type_image_train)
        images[key] = image_transformed
        labels[key] = int(ref_filename[-7])
        
        # save the rotated image to disk
        filename = '{:s}/mesure{:04d}.{:s}'.format(train, i+1, type_image_train)
        cv2.imwrite(filename, image_transformed)
        
    a_file = open("{:s}/labels.pkl".format(train), "wb")
    pickle.dump(labels, a_file)
    a_file.close()
        
    print('[INFO] Generating Dataset....... (This may take a while. Have a Coffee)')
    dataset = load_dataset(images, labels)
    return dataset 


def load_files_to_dataset(img_path='appr/origin',  type_image_train='png', label_path='appr/origin', label_filename='labels.pkl', max_num=None):
    print('[INFO] Loading Resource Files....... ')
    labels_file = open('{:s}/{:s}'.format(label_path, label_filename), "rb")
    labels = pickle.load(labels_file)
    images = load_dir_images(dir_name = img_path, img_type=type_image_train, grayscale=True, N=max_num)
    slice_keys = [w[-14:] for w in list(images.keys())]
    new_images = dict(zip(slice_keys, list(images.values())))
    
    print('[INFO] Generating Dataset.......')
    dataset = load_dataset(new_images, labels)
    print('[INFO] Loading Done!')
    return dataset

if __name__ == '__main__':
    dataset = gene_train_images()
