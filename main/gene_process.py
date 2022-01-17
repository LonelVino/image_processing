import os
import sys
import inspect

currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0, parentdir) 

import numpy as np
import pickle

from generate import gene_train_images, load_files_to_dataset
from image_process import PreProcessing
from utlis import save_images, save_dict, str2bool
from visualize import disp_multi_images

from argparse import ArgumentParser, RawTextHelpFormatter
parser = ArgumentParser(description="Generate or Load Original images, and then generate Processed Images.", formatter_class=RawTextHelpFormatter)
parser.add_argument('-N', '--num', metavar='Number', type=int, nargs='?',
                    help='Number of Generated Images (Only required when generating images)', 
                    required=False, default = 500)
parser.add_argument('-L', '--is_load', metavar='BOOLEAN', type=str2bool, nargs='?',
                    required=False, default = False,
                    help="Load original images from folder")
parser.add_argument('-OPth', '--img_path', metavar='Path', type=str, nargs='?',
                    help='Path of Original images', 
                    required=False, default = 'appr/origin')
parser.add_argument('-SPth', '--save_path', metavar='Path', type=str, nargs='?',
                    help='Path of images to save', 
                    required=False, default = 'appr')
parser.add_argument('-rT', '--ref_img_type', metavar='Type', type=str, nargs='?',
                    help='Type of reference images to load', 
                    required=False, default = 'bmp')
parser.add_argument('-T', '--img_type', metavar='Type', type=str, nargs='?',
                    help='Type of origin images to save / Type of images to save', 
                    required=False, default = 'png')
parser.add_argument('-DS', '--gene_dataset', metavar='BOOLEAN',  type=str2bool, nargs='?',
                    required=False, default = True,
                    help="Generate Dataset when loading images")
parser.add_argument('-P', '--process', metavar='BOOLEAN',  type=str2bool, nargs='?',
                    required=False, default = True,
                    help="Process orignal images (binarized, contour, fft)")


args = parser.parse_args()
num = args.num; is_load = args.is_load; 
img_path = args.img_path; save_path = args.save_path;
ref_img_type = args.ref_img_type; img_type = args.img_type; 
is_gene_dataset = args.gene_dataset; is_process = args.process

print('\n[INFO] Generating Training Images ... ')
if is_gene_dataset:
    if not is_load:
        origin_path = save_path+'/origin'
        train_data = gene_train_images(ref=img_path, train = origin_path,\
            type_image_ref=ref_img_type, type_image_train=img_type, N=num)
        images = train_data.images; file_names = train_data.filenames
    else:
        train_data = load_files_to_dataset(img_path=img_path,  type_image_train=img_type, \
            label_path=img_path, label_filename='labels.pkl')
        images = train_data.images; file_names = train_data.filenames
else:
    if not is_load:
        origin_path = save_path+'/origin'
        file_names, images = gene_train_images(ref=img_path, train = origin_path,\
            type_image_ref=ref_img_type, type_image_train=img_type, N=num, gene_dataset=is_gene_dataset)
    else:
        file_names, images = load_files_to_dataset(img_path=img_path,  type_image_train=img_type, \
            label_path=img_path, label_filename='labels.pkl', gene_dataset=is_gene_dataset)
        

print('_'*80)
print('Image Size: ', np.shape(images))
print('_'*80)


if is_process:
    PreProcesser = PreProcessing()

    print('\n[INFO] Generating Binarized Images ... ')
    images_binarized = PreProcesser.binarize(images)
    print('\n[INFO] Generating Contour Images ... ')
    images_contour = PreProcesser.findContour(images_binarized)
    print('\n[INFO] Generating Centralized Images ... ')
    images_centralized = PreProcesser.Centralize(images_contour)
    print('\n[INFO] Generating FFT Images ... ')
    images_fft, images_fft_log = PreProcesser.FFT(images_centralized)

    # disp_multi_images(images_contour)
    # disp_multi_images(images_fft_log)

    print('\n[INFO] Saving Binarized Images ... ')
    save_images(images_binarized, save_path+'/binarized/', file_names, img_type='png', clear_cache=True)

    print('\n[INFO] Saving Contour Images ... ')
    save_images(images_contour, save_path+'/contour/', file_names, img_type='png', clear_cache=True)

    print('\n[INFO] Saving Centralized Contour Images ... ')
    save_images(images_centralized, save_path+'/contour_central/', file_names, img_type='png', clear_cache=True)

    print('\n[INFO] Saving FFT Images ... ')
    save_images(images_fft_log, save_path+'/fft/', file_names, img_type='png', clear_cache=True)

    # Save labels of images
    if not is_load:
        labels_file = open("./"+origin_path+"/labels.pkl", "rb")
    else:
        labels_file = open("./"+img_path+"/labels.pkl", "rb")
    labels = pickle.load(labels_file)    
    save_dict(labels, path=save_path+'/binarized/labels.pkl')
    save_dict(labels, path=save_path+'/contour/labels.pkl')
    save_dict(labels, path=save_path+'/contour_central/labels.pkl')
    save_dict(labels, path=save_path+'/fft/labels.pkl')
