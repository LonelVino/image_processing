import matplotlib.pyplot as plt
import numpy as np
import pickle
from utlis import load_dir_images

if __name__ == '__main__':
    train='appr'
    type_image_train='png'
    img_train_dict = load_dir_images(dir_name = './'+train, img_type=type_image_train)
    img_train_names = list(img_train_dict.keys())
    labels_file = open("./{:s}/labels.pkl".format(train), "rb")
    labels = pickle.load(labels_file)

    np.random.seed(19680801)
    fig, ax = plt.subplots()

    for i in range(len(img_train_dict)):
        ax.cla()
        filename = img_train_names[i]
        ax.imshow(img_train_dict[filename])
        ax.set_title("Path: {:s};  Class: {:d}".format(filename, labels['./' + filename]))
        # Note that using time.sleep does *not* work here!
        plt.pause(0.3)
