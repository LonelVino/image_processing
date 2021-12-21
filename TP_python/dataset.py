from sklearn.utils import Bunch
import numpy as np

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
    '''
    data = np.empty(0)
    target = np.empty(0)
    feature_names = np.empty(0)
    target_names = np.unique(list(labels.values()))
    data_images = np.array(list(images.values()))
    DESCR = 'Images transformed based on 6 reference samples'
    for filename, img in images.items():
        np.append(target, labels[filename])
        np.append(data, img.flatten())
    for i in range(np.shape(data_images[0])[0]):
        base = 'pixel_' + str(i) + '-'
        for j in range(np.shape(data_images[0])[1]):
            np.append(feature_names, base + str(j))
    dataset = Bunch(data=data, target=target, feature_names=feature_names,\
                    target_names=target_names, images=data_images, DESCR=DESCR)
