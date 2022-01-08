import os
import sys
import inspect

currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0, parentdir) 

import numpy as np
import pickle
from argparse import ArgumentParser, RawTextHelpFormatter

from generate import gene_train_images, load_files_to_dataset
from image_process import PreProcessing
from utlis import save_images, save_dict, disp_multi_images, str2bool


parser = ArgumentParser(description="Generate or Load Original images, and then generate Processed Images.", formatter_class=RawTextHelpFormatter)
parser.add_argument('-N', '--num', metavar='Number', type=int, nargs='?',
                    help='Number of Generated Images', 
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
parser.add_argument('-T', '--img_type', metavar='Type', type=str, nargs='?',
                    help='Type of images to load', 
                    required=False, default = 'png')

args = parser.parse_args()
num = args.num; is_load = args.is_load; 
img_path = args.img_path; img_type = args.img_type; 
save_path = args.save_path

print('\n[INFO] Generating Training Images ... ')
if not is_load:
    train_data = gene_train_images(train=img_path, type_image_train=img_type, N=num)
else:
    train_data = load_files_to_dataset(img_path=img_path,  type_image_train=img_type, \
        label_path=img_path, label_filename='labels.pkl')
images = train_data.images; data = train_data.data
target = train_data.target; target_names = train_data.target_names
file_names = train_data.filenames

print('_'*80)
print('Data Size: ', np.shape(data), '\nImage Size: ', np.shape(images), \
    'Number of Features: ', np.shape(train_data.feature_names), '\nTarget: ', target_names)
print('_'*80)

PreProcesser = PreProcessing()

print('\n[INFO] Generating Binarized Images ... ')
images_binarized = PreProcesser.binarize(images)
print('\n[INFO] Generating Contour Images ... ')
images_contour = PreProcesser.findContour(images_binarized)
print('\n[INFO] Generating Centralized Images ... ')
images_centralized = PreProcesser.Centralize(images_contour)
print('\n[INFO] Generating FFT Images ... ')
images_fft, images_fft_log = PreProcesser.FFT(images_centralized)
print('\n[INFO] Generating Reconstructed Images ... ')
images_back = PreProcesser.Reconstruct(images_fft)

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
labels_file = open("./"+img_path+"/labels.pkl", "rb")
labels = pickle.load(labels_file)    
save_dict(labels, path=save_path+'/binarized/labels.pkl')
save_dict(labels, path=save_path+'/contour/labels.pkl')
save_dict(labels, path=save_path+'/contour_central/labels.pkl')
save_dict(labels, path=save_path+'/fft/labels.pkl')
