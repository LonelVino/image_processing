import numpy as np
from time import time
from sklearn import metrics
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt

def retrieve_info(cluster_labels,true_labels):
    '''
     Associates most probable label with each cluster in KMeans model
     returns: dictionary of clusters assigned to each label
    '''
    # Initializing
    reference_labels = {}
    # For loop to run through each label of cluster label
    for i in np.unique(cluster_labels):
        index = np.where(cluster_labels == i,1,0)
        num = np.bincount(true_labels[index==1]).argmax()
        reference_labels[i] = num
    return reference_labels


def bench_kmeans(clf, clf_name, X_train, X_val, y_train, y_val):
    """Benchmark to evaluate the KMeans initialization methods.

    Parameters
    ----------
    clf : KMeans instance
        A :class:`~sklearn.cluster.KMeans` instance with the initialization
        already set.
    num_cluster : str
        Number of clusters given to the strategy. It will be used to show the results in a
        table.
    data : ndarray of shape (n_samples, n_features)
        The data to cluster.
    labels : ndarray of shape (n_samples,)
        The labels used to compute the clustering metrics which requires some
        supervision.
    """

    try:
        t0 = time()
        clf = clf.fit(X_train, y_train) 
    except:
        print('Invalid in Classification')
    
    y_pred = clf.predict(X_val)
    reference_labels = retrieve_info(y_pred, y_val.astype(int))  # cluster labels
    predict_labels = list(map(lambda x: reference_labels[x], y_pred))  # true predict labels
    clf_fit_pred_time = time() - t0
    results = [clf_name, clf_fit_pred_time, clf.inertia_]
    results.append(metrics.accuracy_score(predict_labels, y_val))
    
    # Define the metrics which require only the true labels and estimator
    # labels
    clustering_metrics = [
        # Add inertia
        metrics.homogeneity_score,
        metrics.completeness_score,
        metrics.v_measure_score,
        metrics.adjusted_rand_score,
        metrics.adjusted_mutual_info_score,
    ]
    results += [m(y_val, y_pred) for m in clustering_metrics]
    

    # Show the results
    formatter_result = (
        "{:5s}\t{:.3f}\t{:.3f}\t{:3f}\t{:.3f}\t{:.3f}\t{:.3f}\t{:.3f}\t{:.3f}"
    )
    print(formatter_result.format(*results))
    return results
    
def find_best_clusters(X_train, X_val, y_train, y_val):
    print(92 * "_")
    print("Kmeans\t\ttime\tinertia\t\tAccuracy\thomo\tcompl\tv-meas\tARI\tAMI")

    kmeans = {}
    all_results = np.array([])
    num_clusters = list(range(4,20,2)) + list(range(20,60,4)) + list(range(50,min(500, len(X_train)),20))
    for num in num_clusters:
        kmeans_name = 'kmeans_'+str(num)
        kmeans[kmeans_name] = KMeans(init="k-means++", n_clusters=num, random_state=43, max_iter=300,
            n_init=6, tol=0.0001, verbose=0)
        results = bench_kmeans(clf=kmeans[kmeans_name], clf_name=kmeans_name,
                    X_train=X_train, X_val=X_val, y_train=y_train, y_val=y_val)
        all_results = np.append(all_results, results)
    print(all_results.shape)
    all_results = all_results.reshape(-1, 9)
    print(92 * "_")
    
    accuracy =  all_results[:,4].astype(float)
    max_n = num_clusters[accuracy.argmax()]
    plt.figure(figsize=(8,6))
    plt.xlabel('Number of clusters', fontsize=14)
    plt.ylabel('Accuracy', fontsize=14)
    plt.title('Accuracy of n-clusters KMeans', fontsize=20)
    plt.plot(num_clusters, accuracy, lw=3)
    plt.axvline(x=max_n, color='red', ls='--')
    plt.text(max_n+2, min(accuracy), str(max_n), fontsize=16, color='red')
    # plt.savefig('best_n_PCA')
    return all_results, max_n

