from sklearn.metrics import classification_report, ConfusionMatrixDisplay, PrecisionRecallDisplay, confusion_matrix
from sklearn.preprocessing import LabelBinarizer
from sklearn.metrics import precision_recall_fscore_support, precision_recall_curve, average_precision_score
from sklearn.metrics import roc_curve, roc_auc_score, auc
from itertools import cycle
import matplotlib.pyplot as plt
import numpy as np


plt.rc('font', family='serif')
plt.rc('xtick', labelsize='x-large')
plt.rc('ytick', labelsize='x-large')
plt.rc('axes', labelsize='x-large', titlesize='x-large')


def Evaluate(y_test, y_pred, y_prob_pred, n_classes, target_names):
    print(classification_report(y_test, y_pred, target_names=target_names.astype(str)))
    cm = confusion_matrix(y_test, y_pred, labels=target_names)
    disp = ConfusionMatrixDisplay(cm, display_labels=target_names)
    disp.plot()
    plt.tight_layout()  # Adjust the padding between and around subplots.
    # plt.savefig('assets/img/ConfusionMatrix(test).png', dpi=300); 
    
    # Binarized Labels {0,1}
    lb = LabelBinarizer()
    lb.fit(y_test)
    y_test_lb = lb.transform(y_test)
    
    precision = dict()
    recall = dict()
    average_precision = dict()
    weighted_score = precision_recall_fscore_support(y_test, y_pred, average='weighted')
    precision['weighted'], recall['weighted'] = weighted_score[0], weighted_score[1]
    average_precision['weighted'] = average_precision_score(y_test_lb, y_prob_pred, average='weighted')

    for i in range(n_classes):
        precision[i], recall[i], _ = precision_recall_curve(y_test_lb[:, i], y_prob_pred[:, i])
        average_precision[i] = average_precision_score(y_test_lb[:, i], y_prob_pred[:, i])
    
    plot_mutliclass_PRC(precision, recall, average_precision, n_classes)
    ROC_score = cal_ROC_score(y_test, y_prob_pred, mode='ovo')
    plot_multiclass_ROC(y_test, y_prob_pred, n_classes)    
    
    results = {'precision': precision, 'recall': recall, 
               'average_precision': average_precision,
               'ROC_score': ROC_score}
    return results


def plot_mutliclass_PRC(precision, recall, average_precision, n_classes):
    # setup plot details
    colors = cycle(["navy", "turquoise", "darkorange", "cornflowerblue", "teal", "orange"])

    fig, ax = plt.subplots(figsize=(7, 8))

    f_scores = np.linspace(0.2, 0.8, num=4)
    lines, labels = [], []
    for f_score in f_scores:
        x = np.linspace(0.01, 1)
        y = f_score * x / (2 * x - f_score)
        (l,) = plt.plot(x[y >= 0], y[y >= 0], color="gray", alpha=0.2)
        plt.annotate("f1={0:0.1f}".format(f_score), xy=(0.9, y[45] + 0.02))

    display = PrecisionRecallDisplay(
        recall=recall["weighted"],
        precision=precision["weighted"],
        average_precision=average_precision["weighted"],
    )
    display.plot(ax=ax, name="Weighted-average precision-recall", color="gold")

    for i, color in zip(range(n_classes), colors):
        display = PrecisionRecallDisplay(
            recall=recall[i],
            precision=precision[i],
            average_precision=average_precision[i],
        )
        display.plot(ax=ax, name=f"Precision-recall for class {i+1}", color=color)

    # add the legend for the iso-f1 curves
    handles, labels = display.ax_.get_legend_handles_labels()
    handles.extend([l])
    labels.extend(["iso-f1 curves"])
    # set the legend and the axes
    ax.set_xlim([0.0, 1.0])
    ax.set_ylim([0.0, 1.05])
    ax.legend(handles=handles, labels=labels, loc="best")
    ax.set_title("Extension of Precision-Recall curve to multi-class")  

    fig.savefig('assets/img/Multiclass_PRC(test).png', dpi=300);  


def plot_multiclass_ROC(y_test, y_prob_pred, n_classes):
    # roc curve for classes
    fpr = {}
    tpr = {}
    thresh = {}
    roc_auc = {}

    for i in range(n_classes):    
        fpr[i], tpr[i], thresh[i] = roc_curve(y_test, y_prob_pred[:,i], pos_label=i)
        roc_auc[i] = auc(fpr[i], tpr[i])
        
    colors = cycle(["navy", "turquoise", "darkorange", "cornflowerblue", "teal", "orange"])
    # plotting    
    plt.figure(figsize=(8,6))
    for i, color in zip(range(n_classes), colors):
        plt.plot(fpr[i], tpr[i], linestyle='--',color=color, \
                label='Class {0} vs Rest (area = {1:0.2f})'.format(i+1, roc_auc[i]),)
    plt.title('Multiclass ROC curve')
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive rate')
    plt.legend(loc='best')
    plt.savefig('assets/img/ROC_curves(test).png',dpi=300);    
    
    
def cal_ROC_score(y_test, y_prob_pred, mode='ovo'):
    # calculate area under roc curve (AUC) for model, we report a macro average, and a prevalence-weighted average.
    score = dict()
    if mode=='ovo':
        score['macro_roc_auc_ovo'] = roc_auc_score(y_test, y_prob_pred, multi_class="ovo", average="macro")
        score['weighted_roc_auc_ovo'] = roc_auc_score(
            y_test, y_prob_pred, multi_class="ovo", average="weighted"
        )
    elif mode=='ovr':
        score['macro_roc_auc_ovr'] = roc_auc_score(y_test, y_prob_pred, multi_class="ovr", average="macro")
        score['weighted_roc_auc_ovr'] = roc_auc_score(
            y_test, y_prob_pred, multi_class="ovr", average="weighted"
        )
    return score
