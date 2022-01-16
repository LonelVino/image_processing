import math
import random
import matplotlib.pyplot as plt
from itertools import cycle
import numpy as np
from sklearn.decomposition import PCA
from sklearn.cluster import KMeans
from matplotlib.colors import ListedColormap
import pickle

from utlis import load_dir_images


def view_dir_images(dir_name='appr/origin', type_image='png'):
    img_train_dict = load_dir_images(dir_name = './'+dir_name, img_type=type_image)
    img_train_names = list(img_train_dict.keys())
    labels_file = open("./{:s}/labels.pkl".format(dir_name), "rb")
    labels = pickle.load(labels_file)

    np.random.seed(19680801)
    fig, ax = plt.subplots()

    for i in range(len(img_train_dict)):
        ax.cla()
        filename = img_train_names[i]
        ax.imshow(img_train_dict[filename])
        ax.set_xticks([]); ax.set_yticks([]) 
        ax.set_title("Path: {:s}".format(filename))
        # Note that using time.sleep does *not* work here!
        plt.pause(0.3)

def disp_multi_images(images, labels=None, suptitle=''):
    ''' Visualize images    
    Args:
        images (np.darray): the  images
    '''
    len_images = len(images) if len(images)<=25 else 25
    num = math.ceil(math.sqrt(len_images))
    idxs = random.sample(range(0, len(images)), len_images)
    
    fig = plt.figure(figsize=(num**2,num**2)) if num > 3 else  plt.figure(figsize=((num+1)**2,(num+1)**2))
    plt.suptitle("Images " + suptitle,  size=16, y=3)
    
    for count, index in enumerate(idxs):
        ax = fig.add_subplot(num, num, count + 1, xticks=[], yticks=[])
        image = images[index]
        ax.imshow(image, cmap='gray')
        if labels is not None:
            ax.set_title('Class {%s}'%labels[index])
        
        if count==len_images-1:
            plt.show()
            break    

def display_mis_images(target_test, y_val_pred, filenames_test, images_test_og, target_test_og, filenames_test_og):
    mis_idxs = [idx for (idx, label) in enumerate(target_test) if (label != y_val_pred[idx])]
    mis_labels = y_val_pred[mis_idxs]
    mis_filenames = filenames_test[mis_idxs]
    print('Number of MISCLASSIFIED images', len(mis_filenames))
    mis_idxs_og = [list(filenames_test_og).index(filename) for (idx, filename) in enumerate(mis_filenames)]
    mis_images = [images_test_og[idx] for idx in mis_idxs_og]
    labels_map = dict(zip(list(range(1,7)), \
                ['circle', 'rect', 'ellipse', 'star', 'H', 'Y']))
    mis_true_labels = [labels_map[target_test_og[idx]] for idx in mis_idxs_og]
    len_images = len(mis_images) if len(mis_images)<=25 else 25
    num = math.ceil(math.sqrt(len_images))
    idxs = random.sample(range(0, len(mis_images)), len_images)
    
    fig = plt.figure(figsize=(num**2,num**2)) if num > 3 else  plt.figure(figsize=((num+1)**2,(num+1)**2))
    plt.title("Misclassified images (True Label - Predicted Label)",  fontsize=16)
    plt.subplots_adjust(hspace=0.5)
    for count, index in enumerate(idxs):
        ax = fig.add_subplot(num, num, count + 1, xticks=[], yticks=[])
        image = mis_images[count]
        ax.set_title('True Label: {:s}\n Predict Label: {:s}'.\
            format(mis_true_labels[count], labels_map[mis_labels[count]]),
                    fontsize=12)
        ax.imshow(image)

        if count==len_images-1:
            break

def visual_KMeans_3d(data_test_pca, predict_labels_test):
    '''
    Visualize 3d plots (3 PCA components)
    '''
    # setup plot details
    colors = cycle(["navy", "turquoise", "darkorange", "cornflowerblue", "teal", "red"])

    fig = plt.figure(figsize = (15,8))

    for idx, ii in enumerate(range(0,90,60)):
        ax = fig.add_subplot(1,2,idx+1, projection='3d')
        ax.view_init(elev=ii, azim=ii)

        for label, color in zip(range(1, 7), colors):
            idxes = np.where([np.array(predict_labels_test)==label])[1]
            cluster = np.array([data_test_pca[idx] for idx in idxes])
            ax.scatter(xs=cluster[:,0], ys=cluster[:,1], zs=cluster[:,2],
                s=40, color=color, label='cluster'+str(label))
        ax.set_xlabel('PCA1'); ax.set_ylabel('PCA2'); ax.set_zlabel('PCA3')
        ax.set_xticks([]); ax.set_yticks([]); ax.set_zticks([])
    plt.subplots_adjust(hspace=0.1, wspace=0.1)
    plt.legend()
    
    
def visual_KMeans_2d(data_test_pca):
    data = data_test_pca[:, 0:2]
    reduced_data = PCA(n_components=2).fit_transform(data)
    kmeans = KMeans(init="k-means++", n_clusters=6, n_init=4)
    kmeans.fit(reduced_data)

    # Create color maps
    cmap_light = ListedColormap(['#FFAAAA', '#FFFAAA', '#AAFFAA', '#AFFFAA','#AAAAFF', '#AAAFFF',])
    cmap_bold = ListedColormap(['#FF0000', '#FFF000', '#00FF00', '#0FFF00', '#0000FF', '#000FFF'])

    # Step size of the mesh. Decrease to increase the quality of the VQ.
    h = 0.02  # point in the mesh [x_min, x_max]x[y_min, y_max].

    # Plot the decision boundary. For that, we will assign a color to each
    x_min, x_max = reduced_data[:, 0].min() - 1, reduced_data[:, 0].max() + 1
    y_min, y_max = reduced_data[:, 1].min() - 1, reduced_data[:, 1].max() + 1
    xx, yy = np.meshgrid(np.arange(x_min, x_max, h), np.arange(y_min, y_max, h))

    # Obtain labels for each point in mesh. Use last trained model.
    Z = kmeans.predict(np.c_[xx.ravel(), yy.ravel()])

    # Put the result into a color plot
    Z = Z.reshape(xx.shape)
    plt.figure(figsize=(15,15)); plt.clf()
    plt.imshow(
        Z, interpolation="nearest",
        extent=(xx.min(), xx.max(), yy.min(), yy.max()),
        cmap=cmap_light,
        aspect="auto", origin="lower",
    )
    plt.scatter(reduced_data[:, 0], reduced_data[:, 1],cmap=cmap_bold)
    # Plot the centroids as a white X
    centroids = kmeans.cluster_centers_
    plt.scatter(
        centroids[:, 0], centroids[:, 1],
        marker="x", s=169,
        linewidths=3, color="w", zorder=10,
    )
    plt.title(
        "K-means clustering on the digits dataset (PCA-reduced data)\n"
        "Centroids are marked with white cross"
    )
    plt.xlim(x_min, x_max); plt.ylim(y_min, y_max)
    plt.xticks(()); plt.yticks(())