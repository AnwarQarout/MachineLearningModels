import pandas
import pandas as pd
import numpy as np
import seaborn as sn
import matplotlib.pyplot as plt
import sklearn
from pandas import DataFrame
from sklearn.compose import ColumnTransformer
from sklearn.metrics import confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn import metrics
from sklearn.preprocessing import OneHotEncoder, StandardScaler, LabelBinarizer
from sklearn.tree import DecisionTreeClassifier
from sklearn.preprocessing import OneHotEncoder
data = pd.read_spss("SefSec_2014_HH_weight new.sav")
pd.set_option('display.max_columns', None)
pd.set_option('display.width', None)
pd.set_option('display.max_colwidth', None)
pd.set_option("display.max_rows", None, "display.max_columns", None)


data['H14'] = data['H14'].cat.codes

data['H12_1B'] = data['H12_1B'].cat.codes

data['H12_2B'] = data['H12_2B'].cat.codes

data['C13_2A'] = data['C13_2A'].cat.codes

data['C13_8A'] = data['C13_8A'].cat.codes

data['I04_1'] = data['I04_1'].cat.codes

data['C13_3A'] = data['C13_3A'].cat.codes

data['C13_12A'] = data['C13_12A'].cat.codes

data['C13_1A'] = data['C13_1A'].cat.codes

data['T3_1_1'] = data['T3_1_1'].cat.codes

data['T3_9_1'] = data['T3_9_1'].cat.codes

data['C12_21'] = data['C12_21'].cat.codes

data['H1'] = data['H1'].cat.codes

data['C09_1A'] = data['C09_1A'].cat.codes

mean = data['C09_1A'].mean()

data['C09_1A'] = data['C09_1A'].fillna(mean)

print(data['H22_3'].describe())




temp = data[['H9','C09_1A','H12_1B','H12_2B','H1','T3_1_1','H22_3','T3_9_1','C12_21','H22_31','C13_2A','C13_8A','I04_1','C13_3A','C13_12A','H22_28','E801_6A','H22_34','H22_17','C13_1A','H14']]
temp=temp.dropna()
temp.hist( figsize = (20,10))
plt.show()
fig, ax = plt.subplots(figsize=(34,34))
sn.heatmap(temp.corr(),annot=True,linewidths=.9,ax=ax)
plt.title("THE CORRELATION MATRIX")
plt.show()

X = temp[['C13_1A','H9','C09_1A','H12_1B','H12_2B','H1','T3_1_1','H22_3','T3_9_1','C12_21','H22_31','C13_2A','C13_8A','I04_1','C13_3A','C13_12A','H22_28','E801_6A','H22_34','H22_17']]
y=temp['H14']

X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=1,test_size=0.3)
clf = DecisionTreeClassifier()
clf.fit(X_train,y_train)

y_pred = clf.predict(X_test)
y_test = np.array(list(y_test))
y_pred = np.array(y_pred)

print("accuracy : ",metrics.accuracy_score(y_test,y_pred))
cf_matrix = confusion_matrix(y_test, y_pred)
sn.heatmap(cf_matrix,annot=True)
plt.show()

#df = pd.DataFrame({'Actual': y_test.flatten(), 'Predicted': y_pred.flatten()})
#df1 = df.head(25)
#df1.plot(kind='bar',figsize=(16,10))
#plt.grid(which='major', linestyle='-', linewidth='0.5', color='green')
#plt.grid(which='minor', linestyle=':', linewidth='0.5', color='black')
#plt.title("LOGISTIC REGRESSION - WILL THE STUDENT SEEK HIGHER EDUCATION?")
#plt.show()












