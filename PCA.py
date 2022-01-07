from time import time
from sklearn import metrics
import matplotlib.pyplot as plt
import numpy as np
from sklearn.model_selection import RandomizedSearchCV
from sklearn.decomposition import PCA

def bench_pcas(PCA, clf, pca_name, clf_name, X_train, X_val, y_train, y_val):
    """Benchmark to evaluate the KMeans initialization methods.

    Parameters
    ----------
    PCA : PCA instance
        A :class:`~sklearn.decomposition.PCA` instance with the initialization
        already set.
    clf : Classifier instance
        A :class: classifier instance with the initialization, such as SVN, kmeans
        already set.
    name : str
        Name given to the strategy. It will be used to show the results in a
        table.
    data : ndarray of shape (n_samples, n_features)
        The data to cluster.
    labels : ndarray of shape (n_samples,)
        The labels used to compute the clustering metrics which requires some
        supervision.
    """
    t0 = time()
    PCA = PCA.fit(X_train)
    pca_fit_time = time() - t0
    X_train_pca = PCA.transform(X_train)
    X_val_pca = PCA.transform(X_val)
    
    t0 = time()
    try:
        clf = clf.fit(X_train_pca, y_train)
    except:
        print('Invalid in Classification')
        return [pca_name, clf_name, pca_fit_time, 0, 0]
    clf_fit_time = time() - t0
    y_pred = clf.predict(X_val_pca)
    
    results = [pca_name, clf_name, pca_fit_time, clf_fit_time]
    
    # Define the metrics which require only the true labels and estimator labels
    clustering_metrics = [
        metrics.accuracy_score,
    ]
    results += [metric_eval(y_val, y_pred) for metric_eval in clustering_metrics]

    # Show the results
    formatter_result = (
        "{:9s}\t{:9s}\t{:.3f}\t{:.3f}\t{:.3f}"
    )
    print(formatter_result.format(*results))
    return results

def find_best_n_PCA(clf, X_train, X_val, y_train, y_val, n_components, clf_name='clf'):
    pcas = {}
    print(92 * "_")
    print("PCA\t\tClassifier\tpca_time(s)\tclf_time(s)\tAccuracy")

    all_results = np.array([])
    for n in n_components:
        pca_name = 'pca_'+str(n)
        pcas[pca_name] = PCA(n_components=n, svd_solver="randomized", whiten=True)
        results = bench_pcas(PCA=pcas[pca_name], clf=clf, pca_name=pca_name, clf_name=clf_name,\
                    X_train=X_train, X_val=X_val,\
                    y_train=y_train, y_val=y_val)
        all_results = np.append(all_results, results)
        
    all_results = all_results.reshape(-1, 5)
    print(92 * "_")
    
    accuracy =  all_results[:,-1].astype(float)
    max_n = n_components[accuracy.argmax()]
    plt.figure(figsize=(8,6))
    plt.xlabel('N components', fontsize=14)
    plt.ylabel('Accuracy', fontsize=14)
    plt.title('Accuracy of n-components PCA', fontsize=20)
    plt.plot(n_components, accuracy, lw=3)
    plt.axvline(x=max_n, color='red', ls='--')
    plt.text(max_n+2, min(accuracy), str(max_n), fontsize=16, color='red')
    # plt.savefig('best_n_PCA')

    return all_results, max_n

