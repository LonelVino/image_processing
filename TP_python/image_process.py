import cv2
import numpy as np
import random
from numpy.fft import fftshift,  ifftshift
from img_shift import translate_img
from tqdm import tqdm

class PreProcessing:
    
    def __init__(self):
        pass
    
    def binarize(self, images):
        images_bn = np.copy(images)
        for idx, img in tqdm(enumerate(images)):
            ret, thresh = cv2.threshold(img, 120, 255, cv2.THRESH_BINARY) # ret is the threshold value
            images_bn[idx] = thresh
        return images_bn

    def findContour(self, images_bn):
        images_c = np.zeros_like(images_bn)
        for idx, img_bn in tqdm(enumerate(images_bn)):
            image_bn_sample = img_bn.astype(np.uint8)
            image_bn_contour = np.zeros_like(image_bn_sample)
            contours = cv2.findContours(image_bn_sample, mode=cv2.RETR_EXTERNAL, method=cv2.CHAIN_APPROX_NONE)
            cntr = contours[0][0] if len(contours) == 2 else contours[1][0]
            cv2.drawContours(image_bn_contour, [cntr], 0, (255,255,255), 1)
            images_c[idx] = image_bn_contour
        return images_c
    
    def FFT(self, images, filter=None, filter_size=None):
        images_size = np.shape(images)
        img_ffts = np.zeros(np.shape(images) + (2,), np.uint8)
        img_ffts_log = np.zeros_like(images)
        for idx, img in tqdm(enumerate(images)):
            img_fft = fftshift(cv2.dft(np.float32(img),flags = cv2.DFT_COMPLEX_OUTPUT))
            img_fft_log = 20*np.log(cv2.magnitude(img_fft[:,:,0], img_fft[:,:,1]))
            if filter is not None:
                height, width = img.shape[:2]
                center = [int(width/2), int(height/2)]  
                if filter == 'HPF':
                    # Apply High Frequency Filter
                    img_fft_log[center[0]-filter_size:center[0]+filter_size, \
                                center[1]-filter_size:center[1]+filter_size] = 0
                if filter == 'LPF':
                    # Apply mask on the image
                    mask = np.zeros((height,width,2), np.uint8)
                    mask[center[0]-filter_size:center[0]+filter_size, \
                        center[1]-filter_size:center[1]+filter_size] = 1
                    img_fft_log *= mask
            img_ffts[idx] = img_fft; img_ffts_log[idx] = img_fft_log
        return img_ffts, img_ffts_log

    def Reconstruct(self, images_fft):
        imgs_back = np.zeros(np.shape(images_fft)[:3])
        for idx, img_fft in tqdm(enumerate(images_fft)):
            img_back = cv2.idft(ifftshift(np.float32(img_fft)))
            img_back = cv2.magnitude(img_back[:,:,0], img_back[:,:,1])
            imgs_back[idx] = img_back
        return imgs_back
            
    def simple_centroid(self, img, show=False):
        # calculate moments of binary image
        M = cv2.moments(img)
        # calculate x,y coordinate of center
        cX = int(M["m10"] / M["m00"])
        cY = int(M["m01"] / M["m00"])
        
        if show:
            # put text and highlight the center
            cv2.circle(img, (cX, cY), 5, (255, 255, 255), -1)
            cv2.putText(img, "centroid", (cX - 25, cY - 25),cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)
            cv2.imshow("Image", img)
            cv2.waitKey(0)
        return cX, cY
    
    def Centralize(self, images):
        images_centralized = []
        for idx, img in tqdm(enumerate(images)):
            height, width = img.shape
            center = (width/2, height/2)
            cx, cy  = self.simple_centroid(img)
            x_align, y_align = center[0] - cx, center[1] - cy
            img_shifted = translate_img(img, (x_align, y_align), with_plot=False)
            images_centralized.append(img_shifted)
        return np.array(images_centralized)
            

def image_random_transform(image):
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
