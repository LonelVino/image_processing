import os
from re import X
import sys
import inspect
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0, parentdir) 

from generate import gene_train_images, load_files_to_dataset
from utlis import disp_multi_images, display_mis_images
from evaluation import Evaluate, evaluate_KMeans
from PCA import find_best_n_PCA
from KMeans import find_best_clusters, retrieve_info

import matplotlib.pyplot as plt

import numpy as np
import warnings
warnings.filterwarnings('ignore')

from sklearn.model_selection import train_test_split,  StratifiedKFold, RandomizedSearchCV
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.neighbors import KNeighborsClassifier as KNN
from sklearn.svm import SVC
from sklearn.cluster import KMeans
from sklearn.utils.fixes import loguniform
from sklearn import metrics
from sklearn.metrics import classification_report, ConfusionMatrixDisplay, PrecisionRecallDisplay, confusion_matrix

from argparse import ArgumentParser, RawTextHelpFormatter, ArgumentTypeError
def str2bool(v):
    if isinstance(v, bool):
        return v
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise ArgumentTypeError('Boolean value expected.')


parser = ArgumentParser(description="Image Classification.", formatter_class=RawTextHelpFormatter)
parser.add_argument('-M','--methods', metavar='Methods', type=str, nargs='+',
                    choices=['KNN', 'KMeans', 'SVM'], help='Classifier', 
                    required=False, default = "KNN")

parser.add_argument('-N', '--num', metavar='Number', type=int, nargs='?',
                    help='Number of Training Images', 
                    required=False, default = 500)

parser.add_argument('-PN', '--pca_n', metavar='Number', type=int, nargs='?',
                    help='Number of PCA Components', 
                    required=False, default = 13)

parser.add_argument('-P', '--pca', metavar='BOOLEAN', type=str2bool, nargs='?',
                    required=False, default = False,
                    help="Find Best Number of Components of PCA")

parser.add_argument('-K', '--kmeans', metavar='BOOLEAN', type=str2bool, nargs='?',
                    help='Find Best Number of clusters of KMeans\n'
                        "(Expected Boolean Value:\n" 
                        "'yes', 'true', 't', 'y', '1'\n" 
                        "'no', 'false', 'f', 'n', '0')" , 
                    required=False, default = False)

args = parser.parse_args()
methods = args.methods; train_num = args.num; pca_n = args.pca_n
find_pca = args.pca; find_kmeans = args.kmeans

# %% ============== 1. Images Loading and Tansformation===============
print('\n============== 1. Images Loading and Tansformation===============')

print('\n[INFO] Loading Train Set.....')
train_set = load_files_to_dataset(img_path='appr/fft',  type_image_train='png', 
    label_path='appr/fft', label_filename='labels.pkl',
    max_num=train_num)

images = train_set.images; data = train_set.data
target = train_set.target; target_names = train_set.target_names
filenames = train_set.filenames; features = train_set.feature_names
n_samples, h, w = np.shape(images)
n_classes = target_names.shape[0]
n_features = features.shape[0]

print('SIZE\t\tTYPE\t  NUMBER of samples\tNUMBER of features\tNUMBER of classes')
print("({:d}, {:d})\t{:9s}\t{:4d}\t\t{:14d}\t{:14d}".\
    format(h, w, str(data[0].dtype), n_samples, n_features, n_classes))
print('_'*80)


print('\n[INFO] Loading Test Set.....')
test_set = load_files_to_dataset(img_path='test/test/fft', type_image_train='png', 
                    label_path='test/test/fft', label_filename='labels.pkl',
                    max_num=500)
data_test = test_set.data; images_test = test_set.images
features_test = test_set.feature_names; filenames_test = test_set.filenames
target_test = test_set.target; target_names_test = test_set.target_names
n_samples_test, h_test, w_test = np.shape(images_test)
n_classes_test = target_names_test.shape[0]
n_features_test = features_test.shape[0]

print('SIZE\t\tTYPE\t  NUMBER of samples\tNUMBER of features\tNUMBER of classes')
print("({:d}, {:d})\t{:9s}\t{:4d}\t\t{:14d}\t{:14d}".\
    format(h_test, w_test, str(data_test[0].dtype), n_samples_test, 
        n_features_test, n_classes_test))
print('_'*80)


# Load Original Images
print('\n[INFO] Loading Original Images in Test Set.....')
test_set_og = load_files_to_dataset(img_path='test/test/origin', type_image_train='png', 
                label_path='test/test/origin', label_filename='labels.pkl',
                max_num=500)


# %% ================= 2. Pre-Processing ====================
print('\n================= 2. Pre-Processing ================')
# Remove INF and NaN value
inf_idx = np.where(np.isinf(np.linalg.norm(data,axis=1)))[0]
nan_idx = np.where(np.isnan(np.linalg.norm(data,axis=1)))[0]
outlier_idx = np.append(inf_idx, nan_idx)
if len(outlier_idx) != 0:
    data = np.delete(data, outlier_idx, axis=0)
    images = np.delete(images, outlier_idx, axis=0)
    target = np.delete(target, outlier_idx, axis=0)
    filenames = np.delete(filenames, outlier_idx, axis=0)
n_samples -= len(outlier_idx)

# Remove INF and NaN value
inf_idx = np.where(np.isinf(np.linalg.norm(data_test,axis=1)))[0]
nan_idx = np.where(np.isnan(np.linalg.norm(data_test,axis=1)))[0]
outlier_idx = np.append(inf_idx, nan_idx)
if len(outlier_idx) != 0:
    data_test = np.delete(data_test, outlier_idx, axis=0)
    images_test = np.delete(images_test, outlier_idx, axis=0)
    target_test = np.delete(target_test, outlier_idx, axis=0)
    filenames_test = np.delete(filenames_test, outlier_idx, axis=0)
n_samples_test -= len(outlier_idx)

images_test_og = np.delete(test_set_og.images, inf_idx, axis=0)
target_test_og = np.delete(test_set_og.target, inf_idx, axis=0)
filenames_test_og = np.delete(test_set_og.filenames, inf_idx, axis=0)

print('_'*80)
# Scaling data
data = np.nan_to_num(data, nan=0.0, posinf=255.0, neginf=0.0)
X_train, X_val, y_train, y_val = train_test_split(  # Split into training and test
    data, target, test_size=0.25, random_state=42
)
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_val = scaler.transform(X_val)


data_test = np.nan_to_num(data_test, nan=0.0, posinf=255.0, neginf=0.0)
scaler_test = StandardScaler() # Scale Data
data_test = scaler_test.fit_transform(data_test)


# %%================= 3.PCA + CLF  ====================
# Define SVC
cv=StratifiedKFold(n_splits=5)
param_grid_SVC = {
    "C": loguniform(1e3, 1e5),
    "gamma": loguniform(1e-4, 1e-1),
}
clf_SVC = RandomizedSearchCV(
    SVC(kernel="rbf", probability=True, class_weight="balanced", decision_function_shape='ovo'),\
    param_grid_SVC, n_iter=50, refit=True,
    scoring='accuracy', cv=cv, 
)

param_grid_KNN = {
    "n_neighbors": np.arange(1,20),
    "weights": ['uniform', 'distance'],
    "p": np.arange(1,5),
}
clf_KNN = RandomizedSearchCV(
    KNN(algorithm="auto", metric='minkowski'),\
    param_grid_KNN, 
    n_iter=10,
    refit=True,
    scoring='accuracy',
    cv=cv, 
)

kmeans_results, best_clusters = find_best_clusters(X_train, X_val, y_train, y_val) if find_kmeans else [], 275
param_grid_KMeans = {
    "n_init": np.arange(5,10),
    "random_state": [0,6,8,42,43,2001]
}
clf_KMeans = RandomizedSearchCV(
    KMeans(init="k-means++", n_clusters=best_clusters, max_iter=300, tol=0.0001, verbose=0), 
    param_grid_KMeans, n_iter=10, refit=True, scoring='accuracy', cv=cv
)

# Train classifier
def train_pca_clf(clf, pca_n, is_KMeans=False):
    if find_pca:
        print('\n[INFO] Find best n components (highest accuracy and less components)')
        n_components = np.unique(np.logspace(1.0,8.0, num=50, base=2.0).astype(int))
        pca_results, pca_n = find_best_n_PCA(clf, X_train, X_val, y_train, y_val, n_components=n_components, clf_name='SVC')
    print("\n[INFO]  Extracting the top %d eigenvalues from %d samples" % (pca_n, X_train.shape[0]))
    pca = PCA(n_components=pca_n, svd_solver="randomized", whiten=True).fit(X_train)

    print("\n[INFO]  Projecting the input data on the eigen orthonormal basis")
    X_train_pca = pca.transform(X_train)
    X_val_pca = pca.transform(X_val)
    
    print("[INFO]  Fitting the SVC classifier to the training set")
    clf = clf.fit(X_train_pca, y_train)

    print("_"*80, "\n[RESULT] Best estimator found by grid search:")
    print(clf.best_estimator_)
    print("_"*80)

    print("\n[INFO]  Predicting symbols on the test set")
    
    y_pred = clf.predict(X_val_pca)
    if is_KMeans:
        # convert cluster labels into true class labels
        reference_labels = retrieve_info(y_pred, y_val.astype(int))  # cluster labels
        predict_labels = np.array(list(map(lambda x: reference_labels[x], y_pred)))  # true predict labels
        return pca, clf, y_pred, reference_labels, predict_labels
    else: 
        y_prob_pred = clf.predict_proba(X_val_pca)
        return pca, clf, y_pred, y_prob_pred


# %% ================= 4. Evaluation ====================
def pred_eval_test(pca, clf, y_pred, y_prob_pred, clf_name='clf'):
    print('================ Evaluate on Validation data ================')
    eval_val = Evaluate(y_val, y_pred, y_prob_pred, n_classes, target_names,
                            mode='VALIDATE', clf_name=clf_name)
    plt.show()
    
    print('================ Evaluate on Test data ================')
    data_test_pca = pca.transform(data_test) # PCA
    y_test_pred = clf.predict(data_test_pca) # classify
    y_test_prob_pred = clf.predict_proba(data_test_pca)
    eval_test = Evaluate(target_test, y_test_pred, y_test_prob_pred,
                            n_classes_test, target_names_test, mode='TEST', clf_name=clf_name)
    display_mis_images(target_test, y_test_pred, filenames_test, images_test_og, target_test_og, filenames_test_og)
    plt.show()
    return y_test_pred, eval_val, eval_test

def pred_eval_test_KMeans(pca_KMeans, clf_KMeans, y_pred_KMeans, predict_labels):
    # Evaluate KMeans
    print('================ Evaluate on Validation data ================')
    eval_val = evaluate_KMeans(y_val, y_pred_KMeans, predict_labels, target_names, mode='Validation')
    print('================ Evaluate on Test data ================')
    data_test_pca = pca_KMeans.transform(data_test) # PCA
    y_test_pred = clf_KMeans.predict(data_test_pca) # classify
    # convert cluster labels into true class labels
    reference_labels_test = retrieve_info(y_test_pred, target_test.astype(int))  # cluster labels
    predict_labels_test = np.array(list(map(lambda x: reference_labels_test[x], y_test_pred)))  # true predict labels
    eval_test = evaluate_KMeans(target_test, y_test_pred, predict_labels_test, target_names, mode='TEST')
    display_mis_images(target_test, predict_labels_test, filenames_test, images_test_og, target_test_og, filenames_test_og)
    plt.show()
    return y_test_pred, eval_val, eval_test


# %% ================= 5. Main Program ====================
### ================== PCA + CLF ========================
if 'SVC' in methods:
    print('\n================ 3. PCA + SVC ================')
    pca_SVC, clf_SVC, y_pred_SVC, y_prob_pred_SVC = train_pca_clf(clf_SVC, pca_n)
    y_test_pred_SVC, eval_val, eval_test = pred_eval_test(pca_SVC, clf_SVC, 
                y_pred_SVC, y_prob_pred_SVC, clf_name='SVC')
if 'KNN' in methods:
    print('\n================ 4. PCA + KNN ================')
    pca_KNN, clf_KNN, y_pred_KNN, y_prob_pred_KNN = train_pca_clf(clf_KNN, pca_n)
    y_test_pred_KNN, eval_val, eval_test = pred_eval_test(pca_KNN, clf_KNN, 
                y_pred_KNN, y_prob_pred_KNN, clf_name='KNN')
if 'KMeans' in methods:
    print('\n================ 5. PCA + KMeans ================')
    pca_KMeans, clf_KMeans, y_pred_KMeans, reference_labels, predict_labels = train_pca_clf(clf_KMeans, pca_n, is_KMeans=True)
    y_test_pred_KMeans, eval_val, eval_test = pred_eval_test_KMeans(
        pca_KMeans, clf_KMeans, y_pred_KMeans, predict_labels
    )


