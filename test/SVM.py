import os
from re import X
import sys
import inspect
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0, parentdir) 

from generate import gene_train_images, load_files_to_dataset
from utlis import disp_multi_images, display_mis_images
from evaluation import Evaluate
from PCA import find_best_n_PCA

import matplotlib.pyplot as plt

import numpy as np
import warnings
warnings.filterwarnings('ignore')

from sklearn.model_selection import train_test_split,  StratifiedKFold, RandomizedSearchCV
from sklearn import metrics
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.svm import SVC
from sklearn.utils.fixes import loguniform
from sklearn.metrics import classification_report, ConfusionMatrixDisplay, PrecisionRecallDisplay, confusion_matrix


#### ============== 1.1 Images Loading and Tansformation===============
print('\n============== 1. Images Loading and Tansformation===============')
# train_set = gene_train_images()
train_set = load_files_to_dataset(img_path='appr/fft',  type_image_train='png', 
    label_path='appr/fft', label_filename='labels.pkl',
    max_num=500)

images = train_set.images
data = train_set.data
target = train_set.target
target_names = train_set.target_names
filenames = train_set.filenames
features = train_set.feature_names

# disp_multi_images(images=images, labels=target, suptitle='Train images')

n_samples, h, w = np.shape(images)
n_classes = target_names.shape[0]
n_features = features.shape[0]

print('_'*80)
print('SIZE\t\tTYPE\t  NUMBER of samples\tNUMBER of features\tNUMBER of classes')
print("({:d}, {:d})\t{:9s}\t{:4d}\t\t{:14d}\t{:14d}".\
    format(h, w, str(data[0].dtype), n_samples, n_features, n_classes))
print('_'*80)

### ================= 1.2 Pre-Processing ====================
print('\n================= 2. Pre-Processing ================')
# Check if inf and NaN value exists
inf_idx = np.where(np.isinf(np.linalg.norm(data,axis=1)))[0]
nan_idx = np.where(np.isnan(np.linalg.norm(data,axis=1)))[0]
outlier_idx = np.append(inf_idx, nan_idx)
if len(outlier_idx) != 0:
    data = np.delete(data, outlier_idx, axis=0)
    images = np.delete(images, outlier_idx, axis=0)
    target = np.delete(target, outlier_idx, axis=0)
    filenames = np.delete(filenames, outlier_idx, axis=0)
n_samples -= len(outlier_idx)

data = np.nan_to_num(data, nan=0.0, posinf=255.0, neginf=0.0)
# Split into training and test
X_train, X_val, y_train, y_val = train_test_split(
    data, target, test_size=0.25, random_state=42
)
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_val = scaler.transform(X_val)

### ================== 1.3 Perform PCA ========================
print('\n================= 3. Perform PCA ================')
# print('\n[INFO] Find best n components (highest accuracy and less components)')
# param_grid = {
#     "C": loguniform(1e3, 1e5),
#     "gamma": loguniform(1e-4, 1e-1),
# }
# clf = RandomizedSearchCV(
#     SVC(kernel="rbf", class_weight="balanced"), param_grid, n_iter=50
# )
# n_components = np.unique(np.logspace(1.0,8.0, num=50, base=2.0).astype(int))
# pca_results, max_n = find_best_n_PCA(clf, X_train, X_val, y_train, y_val, n_components=n_components, clf_name='SVC')

max_n = 13
print("\n[INFO]  Extracting the top %d eigenvalues from %d samples" % (max_n, X_train.shape[0]))
pca = PCA(n_components=max_n, svd_solver="randomized", whiten=True).fit(X_train)

print("\n[INFO]  Projecting the input data on the eigen orthonormal basis")
X_train_pca = pca.transform(X_train)
X_val_pca = pca.transform(X_val)

### ==================== 1.4 SVM.SVC ==========================
print('\n================ 4. SVM.SVC ================')
print("[INFO]  Fitting the SVC classifier to the training set")

param_grid = {
    "C": loguniform(1e3, 1e5),
    "gamma": loguniform(1e-4, 1e-1),
}
cv=StratifiedKFold(n_splits=5)
clf = RandomizedSearchCV(
    SVC(kernel="rbf", probability=True, class_weight="balanced", decision_function_shape='ovo'),\
    param_grid, 
    n_iter=50,
    refit=True,
    scoring='accuracy',
    cv=cv, 
    )
clf = clf.fit(X_train_pca, y_train)

print("_"*80, "\n[RESULT] Best estimator found by grid search:")
print(clf.best_estimator_)
print("_"*80)

print("\n[INFO]  Predicting symbols on the test set")
y_pred = clf.predict(X_val_pca)
y_prob_pred = clf.predict_proba(X_val_pca)

### ===================== 1.5 Evaluate =====================
print('================ 5.1 Evaluate on Validation data ================')
eval_results = Evaluate(y_val, y_pred, y_prob_pred, n_classes, target_names)
plt.show()

print('================ 5.2 Evaluate on Test data ================')
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

print('_'*80)
print('SIZE\t\tTYPE\t  NUMBER of samples\tNUMBER of features\tNUMBER of classes')
print("({:d}, {:d})\t{:9s}\t{:4d}\t\t{:14d}\t{:14d}".\
    format(h_test, w_test, str(data_test[0].dtype), n_samples_test, 
        n_features_test, n_classes_test))
print('_'*80)

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

data_test = np.nan_to_num(data_test, nan=0.0, posinf=255.0, neginf=0.0)
scaler_test = StandardScaler() # Scale Data
data_test = scaler_test.fit_transform(data_test)

data_test_pca = pca.transform(data_test) # PCA
y_test_pred = clf.predict(data_test_pca) # classify
y_test_prob_pred = clf.predict_proba(X_val_pca)

# Evaluate
# test_eval_results = Evaluate(target_test, y_test_pred, y_test_prob_pred, n_classes_test, target_names_test)
print('CLASSIFICATION REPORT ....')
print(classification_report(target_test, y_test_pred, target_names=target_names.astype(str)))
cm = metrics.confusion_matrix(target_test, y_test_pred, labels=target_names)
disp = ConfusionMatrixDisplay(cm, display_labels=target_names)
disp.plot()
plt.title('Confusion Matrix of Test Set')
plt.tight_layout()
plt.show()

# Display misclassified images
print('\n[INFO] Loading Original Images in Test Set.....')
test_set_og = load_files_to_dataset(img_path='test/test/origin', type_image_train='png', 
                label_path='test/test/origin', label_filename='labels.pkl',
                max_num=500)
images_test_og = np.delete(test_set_og.images, inf_idx, axis=0)
target_test_og = np.delete(test_set_og.target, inf_idx, axis=0)
filenames_test_og = np.delete(test_set_og.filenames, inf_idx, axis=0)

display_mis_images(target_test, y_test_pred, filenames_test, images_test_og, target_test_og, filenames_test_og)
plt.show()

