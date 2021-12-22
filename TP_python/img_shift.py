import numpy as np
import matplotlib.pyplot as plt


def pad_vector(vector, how, depth, constant_value=0):
    '''
    A padding function 
    Parameters
    ------------
        vector (2d-array): a matrix in which the padding is done.
        how (str): this takes four values that decide the quadrants where the image needs to be shifted.
            lower or bottom, upper or top, right, left
        depth (int): the depth of the padding.
        constant_value (int): signifies black color and 0 is the default value.
    Returns
    -------------
        pv (2d-array): images after adding padding
    '''
    vect_shape = vector.shape[:2]
    depth = int(depth)
    if (how == 'upper') or (how == 'top'):
        pp = np.full(shape=(depth, vect_shape[1]), fill_value=constant_value)
        pv = np.vstack(tup=(pp, vector))
    elif (how == 'lower') or (how == 'bottom'):
        pp = np.full(shape=(depth, vect_shape[1]), fill_value=constant_value)
        pv = np.vstack(tup=(vector, pp))
    elif (how == 'left'):
        pp = np.full(shape=(vect_shape[0], depth), fill_value=constant_value)
        pv = np.hstack(tup=(pp, vector))
    elif (how == 'right'):
        pp = np.full(shape=(vect_shape[0], depth), fill_value=constant_value)
        pv = np.hstack(tup=(vector, pp))
    else:
        return vector
    return pv

def y_shifter(vect, y, y_):
    if (y > 0):
        image_trans = pad_vector(vector=vect, how='lower', depth=y_)
    elif (y < 0):
        image_trans = pad_vector(vector=vect, how='upper', depth=y_)
    else:
        image_trans = vect
    return image_trans

def shift_image(image_src, at):
    x, y = at
    x_, y_ = abs(x), abs(y)

    if (x > 0):
        left_pad = pad_vector(vector=image_src, how='left', depth=x_)
        image_trans = y_shifter(vect=left_pad, y=y, y_=y_)
    elif (x < 0):
        right_pad = pad_vector(vector=image_src, how='right', depth=x_)
        image_trans = y_shifter(vect=right_pad, y=y, y_=y_)
    else:
        image_trans = y_shifter(vect=image_src, y=y, y_=y_)

    return image_trans

def translate_img(image_src, at, with_plot=False, gray_scale=True):
    if len(at) != 2: return False
    if not gray_scale:
        r_image, g_image, b_image = image_src[:, :, 0], image_src[:, :, 1], image_src[:, :, 2]
        r_trans = shift_image(image_src=r_image, at=at)
        g_trans = shift_image(image_src=g_image, at=at)
        b_trans = shift_image(image_src=b_image, at=at)
        image_trans = np.dstack(tup=(r_trans, g_trans, b_trans))
    else:
        image_trans = shift_image(image_src=image_src, at=at)

    if with_plot:
        cmap_val = None if not gray_scale else 'gray'
        fig, (ax1, ax2) = plt.subplots(nrows=1, ncols=2, figsize=(10, 20))
        ax1.title.set_text('Original'); ax1.axis("off")
        ax2.title.set_text("Translated"); ax2.axis("off")
        ax1.imshow(image_src, cmap=cmap_val)
        ax2.imshow(image_trans, cmap=cmap_val)
        return True
    return image_trans
