import os
import sys
import inspect

currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0, parentdir) 

import numpy as np
from numpy.lib.npyio import save
import pickle

from generate import gene_train_images, load_files_to_dataset
from image_process import PreProcessing
from utlis import save_images, save_dict, disp_multi_images

print('\n[INFO] Generating Training Images ... ')
train_data = gene_train_images(N=100)
# train_data = load_files_to_dataset(img_path='appr/origin',  type_image_train='png', \
    # label_path='appr/origin', label_filename='labels.pkl')
images = train_data.images
data = train_data.data
target = train_data.target
target_names = train_data.target_names
file_names = train_data.filenames

print('_'*80)
print('Data Size: ', np.shape(data), '\nImage Size: ', np.shape(images), \
    'Number of Features: ', np.shape(train_data.feature_names), '\nTarget: ', target_names)
print('_'*80)

PreProcessing = PreProcessing()

print('\n[INFO] Generating Binarized Images ... ')
images_binarized = PreProcessing.binarize(images)
print('\n[INFO] Generating Contour Images ... ')
images_contour = PreProcessing.findContour(images_binarized)
print('\n[INFO] Generating Centralized Images ... ')
images_centralized = PreProcessing.Centralize(images_contour)
print('\n[INFO] Generating FFT Images ... ')
images_fft, images_fft_log = PreProcessing.FFT(images_centralized)
print('\n[INFO] Generating Reconstructed Images ... ')
images_back = PreProcessing.Reconstruct(images_fft)

# disp_multi_images(images_contour)
# disp_multi_images(images_fft_log)

print('\n[INFO] Saving Binarized Images ... ')
save_images(images_binarized, 'appr/binarized/', file_names, img_type='png', clear_cache=True)

print('\n[INFO] Saving Contour Images ... ')
save_images(images_contour, 'appr/contour/', file_names, img_type='png', clear_cache=True)

print('\n[INFO] Saving Centralized Contour Images ... ')
save_images(images_centralized, 'appr/contour_central/', file_names, img_type='png', clear_cache=True)

print('\n[INFO] Saving FFT Images ... ')
save_images(images_fft_log, 'appr/fft_/', file_names, img_type='png', clear_cache=True)

# Save labels of images
labels_file = open("./appr/origin/labels.pkl", "rb")
labels = pickle.load(labels_file)    
save_dict(labels, path='appr/binarized/labels.pkl')
save_dict(labels, path='appr/contour/labels.pkl')
save_dict(labels, path='appr/contour_central/labels.pkl')
save_dict(labels, path='appr/fft_/labels.pkl')
