from pathlib import Path
import cv2

# load reference images
def load_dir_images(dir_name, img_type):
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
        img_dict[str(filename)] = cv2.imread(str(filename))
    return img_dict
