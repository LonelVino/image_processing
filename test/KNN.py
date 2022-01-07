import os
import sys
import inspect
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0, parentdir) 

from generate import gene_train_images, load_files_to_dataset
from utlis import disp_multi_images
from evaluation import Evaluate

from time import time
import matplotlib.pyplot as plt
import numpy as np
import warnings
warnings.filterwarnings('ignore')

from sklearn.model_selection import train_test_split,  StratifiedKFold, RandomizedSearchCV
from sklearn import metrics
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.neighbors import KNeighborsClassifier as KNN
from sklearn.utils.fixes import loguniform

#### ============== 1.1 Images Loading and Tansformation===============
print('\n============== 1. Images Loading and Tansformation===============')
# train_set = gene_train_images()
print('\n[INFO] Loading Train Set.....')
train_set = load_files_to_dataset(img_path='appr/fft',  type_image_train='png', 
    label_path='appr/fft', label_filename='labels.pkl',
    max_num=200)

images = train_set.images
data = train_set.data
target = train_set.target
target_names = train_set.target_names
filenames = train_set.filenames
features = train_set.feature_names

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
# Check if inf value exists
inf_idx = np.where(np.isinf(np.linalg.norm(data,axis=1)))[0]
if len(inf_idx) != 0:
    data = np.delete(data, inf_idx, axis=0)
    images = np.delete(images, inf_idx, axis=0)
    target = np.delete(target, inf_idx, axis=0)
    filenames = np.delete(filenames, inf_idx, axis=0)
n_samples -= len(inf_idx)

data = np.nan_to_num(data, nan=0.0, posinf=255.0, neginf=0.0)
# Split into training and test
X_train, X_val, y_train, y_val = train_test_split(
    data, target, test_size=0.25, random_state=42
)
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_val = scaler.transform(X_val)


### ================== 1.3 Perform KNN ========================
print('\n================= 3. Perform KNN ================')
n_components = 13

print("\n[INFO]  Extracting the top %d eigenvalues from %d samples" % (n_components, X_train.shape[0]))
pca = PCA(n_components=n_components, svd_solver="randomized", whiten=True).fit(X_train)

print("\n[INFO]  Projecting the input data on the eigen orthonormal basis (PCA components)")
X_train_pca = pca.transform(X_train)
X_val_pca = pca.transform(X_val)

### ==================== 1.4 KNN ==========================
print('\n================ 4. KNN ================')
print("\n[INFO]  Fitting the KNN classifier to the training set")

param_grid = {
    "n_neighbors": np.arange(1,20),
    "weights": ['uniform', 'distance'],
    "p": np.arange(1,5),
}
cv=StratifiedKFold(n_splits=5)
clf = RandomizedSearchCV(
    KNN(algorithm="auto", metric='minkowski'),\
    param_grid, 
    n_iter=10,
    refit=True,
    scoring='accuracy',
    cv=cv, 
    )
clf = clf.fit(X_train_pca, y_train)
print("Best estimator found by grid search:")
print(clf.best_estimator_)

KNN_ = clf.best_estimator_
print('The distance metric used: ', KNN_.effective_metric_)
print('Class labels known to the classifier: ', KNN_.classes_)
print('Number of features seen during fit: ', KNN_.n_features_in_)
print("\n[INFO]  Predicting symbols on the validation set")

y_pred = clf.predict(X_val_pca)
y_prob_pred = clf.predict_proba(X_val_pca)

### ===================== 1.5 Evaluate =====================
print('================ 5.1 Evaluate on Validation data ================')
eval_results = Evaluate(y_val, y_pred, y_prob_pred, n_classes, target_names)
plt.show()

