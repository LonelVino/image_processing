import seaborn as sns
import matplotlib.pyplot as plt
from scipy.stats import zscore
import numpy as np

def remove_outlier(train_set, labels, is_plot=False):
    # Remove Outliers 
    Z_scores_1 = zscore(train_set[:,0])
    train_outlier = np.where(Z_scores_1>2.0)[0]
    train_set_ = np.delete(train_set, train_outlier, axis=0)
    labels_ = np.delete(labels, train_outlier, axis=0)

    if is_plot:
        plt.figure(figsize=(8,16))
        plt.suptitle('Upper 2 rows - with outliers; \n Lower 2 rows - after removing)', fontsize=20)
        ax1 = plt.subplot(421); ax1=sns.boxplot(train_set[:,0])
        ax2 = plt.subplot(422); ax2=sns.boxplot(train_set[:,1])
        ax3 = plt.subplot(423); ax3=sns.distplot(train_set[:,0])
        ax4 = plt.subplot(424); ax4=sns.distplot(train_set[:,1])
        ax5 = plt.subplot(425); ax5=sns.boxplot(train_set_[:,0])
        ax6 = plt.subplot(426); ax6=sns.boxplot(train_set_[:,1])
        ax7 = plt.subplot(427); ax7=sns.distplot(train_set_[:,0])
        ax8 = plt.subplot(428); ax8=sns.distplot(train_set_[:,1])
    plt.subplots_adjust(hspace=0.1, wspace=0.1)
    return train_set_, labels_
