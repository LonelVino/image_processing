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

**Validation Set**

```
			 precision    recall  f1-score   support

           1       0.96      1.00      0.98       237
           2       0.83      0.88      0.85       201
           3       0.96      0.99      0.97       204
           4       0.91      0.94      0.92       201
           5       0.81      0.77      0.79       186
           6       0.96      0.86      0.90       221

    accuracy                           0.91      1250
   macro avg       0.90      0.90      0.90      1250
weighted avg       0.91      0.91      0.91      1250
```

**Test Set**

```
              precision    recall  f1-score   support

           1       0.99      0.99      0.99        81
           2       0.86      0.94      0.89        95
           3       0.93      1.00      0.97        71
           4       0.97      0.96      0.96        95
           5       0.85      0.80      0.82        69
           6       0.99      0.89      0.93        88

    accuracy                           0.93       499
   macro avg       0.93      0.93      0.93       499
weighted avg       0.93      0.93      0.93       499
```

### SVC

**Validation Set**

```
precision    recall  f1-score   support

           1       1.00      1.00      1.00       237
           2       0.98      0.95      0.96       201
           3       1.00      1.00      1.00       204
           4       0.97      0.99      0.98       201
           5       0.93      0.97      0.95       186
           6       1.00      0.97      0.98       221

    accuracy                           0.98      1250
   macro avg       0.98      0.98      0.98      1250
weighted avg       0.98      0.98      0.98      1250
```

**Test Set**

```
precision    recall  f1-score   support

           1       1.00      0.99      0.99        82
           2       1.00      0.88      0.94        95
           3       1.00      1.00      1.00        71
           4       0.95      1.00      0.97        95
           5       0.86      0.96      0.90        69
           6       1.00      0.99      0.99        88

    accuracy                           0.97       500
   macro avg       0.97      0.97      0.97       500
weighted avg       0.97      0.97      0.97       500
```

```
Weighted Precision: 0.979592
Weighted Recall: 0.979200
Weighted fbeta Score: 0.979256


One-vs-One ROC AUC scores:
0.997935 (macro),
0.998000 (weighted by prevalence)
One-vs-Rest ROC AUC scores:
0.998026 (macro),
0.998073 (weighted by prevalence)
```