# Characterization of forms and classification

![](https://img.shields.io/badge/Python-v3.8-orange) ![](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)![Visual Studio Code](https://img.shields.io/badge/Visual%20Studio%20Code-0078d7.svg?style=for-the-badge&logo=visual-studio-code&logoColor=white) ![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white) ![NumPy](https://img.shields.io/badge/numpy-%23013243.svg?style=for-the-badge&logo=numpy&logoColor=white) ![scikit-learn](https://img.shields.io/badge/scikit--learn-%23F7931E.svg?style=for-the-badge&logo=scikit-learn&logoColor=white) 

Based on [PCA](https://en.wikipedia.org/wiki/Principal_component_analysis), synthesize 3 classifier ([KNN](https://en.wikipedia.org/wiki/K-nearest_neighbors_algorithm), [KMeans](https://en.wikipedia.org/wiki/K-means_clustering), [SVM](https://en.wikipedia.org/wiki/Support-vector_machine)), with generating images set from the scratch, achieve high test accuracy: *95%* of **KNN**, *93%* of **KMeans** and *97%* of **SVM**.

## Prerequisites

#### Dependencies

 * [Numpy](http://www.numpy.org/)
 * [cv2](https://pypi.org/project/opencv-python/)
 * [Matlplotlib](http://matplotlib.org/) (for graphing)
 * [sklearn](https://pypi.org/project/playground/) 
 * [tqdm](https://github.com/tqdm/tqdm)
 * [pickle](https://docs.python.org/3/library/pickle.html)

```bash
git clone git@github.com:LonelVino/image_processing.git
cd image_processing
pip install -r requirements.txt
```

#### Dataset

The train and test images can be found in [kaggle dataset](https://www.kaggle.com/lonelvino/img-clf-cs).

Please download the image data set and save it in the parent path of this project, named the folder containing the training images **'appr'**, named the folder containing the test images **'appr'**, as shown below:

```
┣ 📦image_processing
   ┣ 📦appr  ### Train Dataset !!!
     ┣ 📂binarized
     ┣ 📂contour
     ┣ 📂contour_central
     ┣ 📂fft
     ┗ 📂origin
   ┣ 📦reference
   ┣ 📦main
   ┣ 📦test  ### Test dataset !!!
     ┣ 📂binarized
     ┣ 📂contour
     ┣ 📂contour_central
     ┣ 📂fft
     ┗ 📂origin
   ┣ 📜KMeans.py
   ┣ 📜PCA.py
   ┣ 📜README.md
   ┣ 📜.........
   ┗ 📜utlis.py
```

## Usage

### Generate Images Dataset

```bash
gene_process.py [-h] [-N [Number]] [-L [BOOLEAN]] [-OPth [Path]] [-SPth [Path]]
                       [-T [Type]]
```
```
optional arguments:
  -h, --help            show this help message and exit
  -N [Number], --num [Number]
                        Number of Generated Images
  -L [BOOLEAN], --is_load [BOOLEAN]
                        Load original images from folder
  -OPth [Path], --img_path [Path]
                        Path of Original images
  -SPth [Path], --save_path [Path]
                        Path of images to save
  -T [Type], --img_type [Type]
                        Type of images to load
```

For example: 
`python3 main/gene_process.py -N 500 -OPth appr/test/origin -SPth appr/test`

By running the command above, *500* transformed images will be generated based on the reference images and be saved in a folder `appr/test/origin`. Then the processed images (binarized, contour, fft) will be generated based on the *500* transformed images and be saved in a folder `/appr/test`.


### Classify

```bash
python3 classify.py  [-h] [-M Methods [Methods ...]] [-N [Number]] [-PN [Number]]
                   [-P [BOOLEAN]] [-K [BOOLEAN]]                
```

```
Optional Arguments:
  -h, --help            show this help message and exit
  -M Methods [Methods ...], --methods Methods [Methods ...]
                        Classifier (KMeans, KNN, SVM)
  -N [Number], --num [Number]
                        Number of Training Images
  -PN [Number], --pca_n [Number]
                        Number of PCA Components
  -P [BOOLEAN], --pca [BOOLEAN]
                        Find Best Number of Components of PCA
  -K [BOOLEAN], --kmeans [BOOLEAN]
                        Find Best Number of clusters of KMeans
                        (Expected Boolean Value:
                        'yes', 'true', 't', 'y', '1'
                        'no', 'false', 'f', 'n', '0')
```

For example: 
`python3 main/classify.py -M KNN KMeans -N 5000 -P yes -K yes`

By running the command above,   *5000* images will be used to train **KMeans** and **KNN** , and then to classify *500* test images, before finding the best number of components in **PCA** and best number of clusters in **KMeans**.

## Performance

#### KNN

1. The best *N* components of **PCA** with **KNN**

<img src="assets/img/KNN/best_n_PCA_KNN.png" alt="ConfusionMatrix" style="zoom:85%;" />

2. **Confusion Matrix on Validation Set and Test Set**

   <img src="assets/img/KNN/ConfusionMatrix.png" alt="ConfusionMatrix" style="zoom:75%; margin-right: 20px" /><img src="assets/img/KNN/ConfusionMatrix(test).png" alt="ConfusionMatrix" style="zoom:75%;" />

3. **Precision-Recall Curve (PRC) and Receiver Operating Characteristic Curve (ROC)**:

   <img src="assets/img/KNN/PRC.png" alt="PRC" style="zoom:70%; margin-right:40px" /><img src="assets/img/KNN/ROC_curves(test).png" alt="PRC" style="zoom:20%;" />

#### KMeans

1. The *best N component*s of **PCA** with **KMeans**, and the *best number of clusters* of **KMeans**:

   <img src="assets/img/K-means/best_n_pca.png" alt="best_n_pca" style="zoom:45%; margin-right:40px" /><img src="assets/img/K-means/best_number_clusters.png" alt="best_n_pca" style="zoom:45%;" />

As we can see above, the *best N component*s of **PCA** is about *<u>16</u>* and the clustering performance improves as the *number of clusters* of **KMeans** increases, according to 5 important metrics ([Inertia](https://scikit-learn.org/stable/modules/clustering.html), [Homogeneity](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.homogeneity_score.html), [Completeness](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.completeness_score.html#sklearn.metrics.completeness_score), [V measure](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.v_measure_score.html), [ARI](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.adjusted_rand_score.html), [AMI](https://scikit-learn.org/stable/modules/generated/sklearn.metrics.adjusted_mutual_info_score.html)).

> Theoretically the more clusters, the better the metrics, however, please note this will result in over-fitting and computation time explosion.

2. **Confusion Matrix on Validation Set and Test Set**

   <img src="assets/img/K-means/ConfusionMatrix.png" alt="ConfusionMatrix" style="zoom:95%; margin-right: 20px" /><img src="assets/img/K-means/ConfusionMatrix (Test Set).png" alt="ConfusionMatrix(test)" style="zoom:95%; margin-right: 20px" />

   

#### SVM

1. The best *N* components of **PCA** with **SVM**

   <img src="assets/img/SVM/best_n_pca.png" alt="best_n_pca" style="zoom:55%;" />

2. **Confusion Matrix on Validation Set and Test Set**

   <img src="assets/img/SVM/ConfusionMatrix.png" alt="ConfusionMatrix" style="zoom:95%; margin-right: 20px" /><img src="assets/img/SVM/ConfusionMatrix_test.png" alt="ConfusionMatrix(test)" style="zoom:95%; margin-right: 20px" />

3. **PRC** curves  and **ROC** curves

    <img src="assets/img/SVM/PRC_curves_zoom_in.png" alt="ROC_curves" style="zoom:60%;" />     <img src="assets/img/SVM/ROC_curves.png" alt="ROC_curves" style="zoom:55%; " />

#### **Example of Misclassified Images**

<img src="assets/img/KNN/Misclassified Images (Test Set).png" alt="Misclassified Images (Test Set)" style="zoom:47%;" />

More classification information, please refer to: [Classification Report](assets/ClassificationReport.md)



## File Structure

```
┣ 📦image_processing
   ┣ 📦appr   # Train Dataset
     ┣ 📂binarized
     ┣ 📂contour
     ┣ 📂contour_central
     ┣ 📂fft
     ┗ 📂origin
   ┣ 📦reference
     ┣ 📜obj101.bmp
     ┣ 📜.........
     ┗ 📜obj601.bmp
   ┣ 📦main
     ┣ 📜classify.py
     ┗ 📜gene_process.py
   ┣ 📦test  # Test dataset 
     ┣ 📂binarized
     ┣ 📂contour
     ┣ 📂contour_central
     ┣ 📂fft
     ┗ 📂origin
   ┣ 📜KMeans.py
   ┣ 📜PCA.py
   ┣ 📜README.md
   ┣ 📜__init__.py
   ┣ 📜classify.py
   ┣ 📜dataset.py
   ┣ 📜evaluation.py
   ┣ 📜generate.py
   ┣ 📜image_process.py
   ┣ 📜img_shift.py
   ┣ 📜requirements.txt
   ┗ 📜utlis.py
```



## Reference

1. Zhang, Qi, et al. "A generic multi-projection-center model and calibration method for light field cameras." *IEEE transactions on pattern analysis and machine intelligence* 41.11 (2018): 2539-2552.
2. Lu, Junwei, et al. "Sparse Principal Component Analysis in Frequency Domain for Time Series."
3. Rama, Antonio, et al. "Partial PCA in frequency domain." *2008 50th International Symposium ELMAR*. Vol. 2. IEEE, 2008.
4. Performance Comparison of Target Classification in SAR Images Based on PCA and 2D-PCA Features Changzhen QIU, Hao REN, Huanxin ZOU, Shilin ZHOU
5. Qiu, Changzhen, et al. "Performance comparison of target classification in SAR images based on PCA and 2D-PCA features." *2009 2nd Asian-Pacific Conference on Synthetic Aperture Radar*. IEEE, 2009.
6. Ayiah-Mensah, Francis, et al. "Recognition of augmented frontal face images using FFT-PCA/SVD algorithm." *Applied Computational Intelligence and Soft Computing* 2021 (2021).
7. Molchanov, Vladimir, and Lars Linsen. "Overcoming the Curse of Dimensionality When Clustering Multivariate Volume Data." *VISIGRAPP (3: IVAPP)*. 2018.
7. [Andrew Rosenberg and Julia Hirschberg, 2007. V-Measure: A conditional entropy-based external cluster evaluation measure](https://aclweb.org/anthology/D/D07/D07-1043.pdf)