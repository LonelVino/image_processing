from sklearn.utils import Bunch
import numpy as np
from tqdm import tqdm

def load_dataset(images, labels):
    '''
    Create dataset Object
    
    Parameters
    -----------
    images (dict): key: filename, value: image (2d-darray)
    labels (dict): key: filename, value: class (int)
    
    Returns
    -----------
    data (Bunch): Dictionary-like object, with the following attributes.
        - data (ndarray): The flattened data matrix of shape (num_samples, num_features)
        - target (ndarray):The classification target of shape (num_samples,)
        - feature_names (list): The names of the dataset columns.
        - target_names (list): The names of target classes.
        - images (ndarray): The raw image data of shape (num_samples, img_width, img_height)
        - DESCR (str):The full description of the dataset.
        - filenames (ndarray): List of filename of all images
    '''
    
    target = np.empty(0)
    feature_names = np.empty(0)
    filenames = np.array(list(images.keys()))
    target_names = np.unique(list(labels.values()))
    data_images = np.array(list(images.values()))
    data = np.empty(np.shape(data_images[0])[0]*np.shape(data_images[0])[1])
    DESCR = 'Images transformed based on 6 reference samples'
    
    for filename, img in tqdm(images.items()):
        data = np.vstack((data, img.flatten()))
        target = np.append(target, labels[filename])
    data = np.delete(data, 1, 0)
    for i in range(np.shape(data_images[0])[0]):
        base = 'pixel_' + str(i) + '-'
        for j in range(np.shape(data_images[0])[1]):
            feature_names = np.append(feature_names, base + str(j))
    dataset = Bunch(data=data, target=target, feature_names=feature_names,\
                    target_names=target_names, images=data_images, DESCR=DESCR, \
                    filenames = filenames)
                    
    return dataset
