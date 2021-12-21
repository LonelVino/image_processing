from pathlib import Path
import random
import os
import pickle
import cv2

from image_process import image_transform, noisy
from dataset import load_dataset
from utlis import load_dir_images

def generate_images(ref='reference', train='appr', type_image_ref='bmp', type_image_train='png', N=100):
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
    # delete all images
    for f in Path('./'+train).glob("*.*"):
        os.remove(f)
        
    # load reference images
    img_ref_dict = load_dir_images(dir_name = './'+ref, img_type=type_image_ref)
    img_ref_names = list(img_ref_dict.keys())
    
    # Generate N training images based on all the reference images by selecting randomly
    labels = {}
    images = {}
    for i in range(N):
        ref_filename = random.choice(img_ref_names)
        image = cv2.imread(ref_filename, cv2.IMREAD_GRAYSCALE)
            image_transformed = image_transform(image)
        filename = './{:s}/mesure{:03d}.{:s}'.format(train, i+1, type_image_train)
        images[filename] = image_transformed
        labels[filename] = int(ref_filename[-7])
        # save the rotated image to disk
        cv2.imwrite(filename, image_transformed)
    a_file = open("./{:s}/labels.pkl".format(train), "wb")
    pickle.dump(labels, a_file)
    a_file.close()
        
    dataset = load_dataset(images, labels)
    return dataset 


if __name__ == '__main__':
    dataset = generate_images()