import cv2
import numpy as np
import random


def image_transform(image):
    '''
    Transform the image randomly, including translation, rotation, scaling, distortion, etc...
    
    Parameters
    -------------
    image (darray): image to be transformed
    
    Returns
    -------------
    final_image (darray): transformed image 
    '''
    image = (255-image)  # convert image into negative image
    height, width = image.shape[:2]
    center = [width/2, height/2]
    
    # ------------- Rotation, scaling and Translation -----------------
    # Parameters of Rotation, scaling and Translation
    rotate_angle = np.degrees(np.pi*random.uniform(-1,1))   # rotation angle in degrees
    scale_size = 0.4 + 0.6*random.uniform(0,1)  # scale size
    tx, ty = width / random.randint(6,9), height / random.randint(6,9) # translation distance
    # Matrix of Rotation, scaling and Translation
    translation_matrix = np.array([
        [1, 0, tx],
        [0, 1, ty]], dtype=np.float32)
    rotate_matrix = cv2.getRotationMatrix2D(center=center, angle=rotate_angle, scale=scale_size)
    # add rotattion, scale and translattion to the image using cv2.warpAffine
    rotated_image = cv2.warpAffine(src=image, M=rotate_matrix, dsize=(width, height))
    translated_image = cv2.warpAffine(src=rotated_image, M=translation_matrix, dsize=(width, height))
    
    # ---------------- Define and Add distortion ----------------------
    A = height / 5.0; w = 1.0 / width
    shift = lambda x: A * np.sin(2.0*np.pi*x * w)
    # Add distortion
    for i in range(image.shape[0]):
        translated_image[:,i] = np.roll(translated_image[:,i], int(shift(i)))
    
    # Enhancement and Noisy, decrease the strength of low gray level value, increase the strength of high gray level value
    final_image = noisy('gauss', translated_image)
    
    return final_image


def noisy(noise_typ,image):
    '''
    Add some noise to input image, the type of noise is chosed by user
    
    Parameters
    ----------
    image (ndarray): Input image data. Will be converted to float.
    mode (str): One of the following strings, selecting the type of noise to add:
        'gauss'     Gaussian-distributed additive noise.
        'poisson'   Poisson-distributed noise generated from the data.
        'speckle'   Multiplicative noise using out = image + n*image,where
                    n is uniform noi
    Return
    -----------
    noisy (ndarray): Image with noise added.
    '''
    row,col = image.shape
    if noise_typ == "gauss":
        mean = 0; var = 0.1; sigma = var**0.5
        gauss = np.random.normal(mean,sigma,(row,col)).reshape(row,col)
        noisy = image + gauss  
    elif noise_typ == "poisson":
        vals = 2 ** np.ceil(np.log2(len(np.unique(image))))
        noisy = np.random.poisson(image * vals) / float(vals)
    elif noise_typ =="speckle":
        gauss = np.random.randn(row,col).reshape(row,col)   
        noisy = image + image * gauss
    return noisy
