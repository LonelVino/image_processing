## Classification Report

### KNN

**Validation Set**

```
				precision    recall  f1-score   support

           1       0.96      1.00      0.98       237
           2       0.93      0.85      0.89       201
           3       1.00      0.99      0.99       204
           4       0.98      0.96      0.97       201
           5       0.81      0.95      0.88       186
           6       0.99      0.92      0.96       221

    accuracy                           0.94      1250
   macro avg       0.95      0.94      0.94      1250
weighted avg       0.95      0.94      0.95      1250
```

 **Test Set**

```
              precision    recall  f1-score   support

           1       0.99      1.00      0.99        81
           2       0.93      0.84      0.88        95
           3       0.97      1.00      0.99        70
           4       0.99      0.95      0.97        95
           5       0.79      0.94      0.86        69
           6       1.00      0.97      0.98        88

    accuracy                           0.95       498
   macro avg       0.95      0.95      0.95       498
weighted avg       0.95      0.95      0.95       498
```

```
One-vs-One ROC AUC scores:
	0.997040 (macro), 0.997204 (weighted by prevalence)
One-vs-Rest ROC AUC scores:
	0.997226 (macro), 0.997390 (weighted by prevalence)
```



### KMeans



### SVM