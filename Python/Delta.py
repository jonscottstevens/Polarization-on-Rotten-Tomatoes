import pandas
import matplotlib.pyplot as plt
from sklearn.cross_validation import train_test_split as ttsplit
from sklearn.feature_extraction.text import CountVectorizer
from xgboost import XGBRegressor
from sklearn.metrics import mean_absolute_error, r2_score

"""
First we read in the .csv RTDelta, which contains columns for user review text as well as user rating and delta score,
which is average critic score - user rating for each review.  We want to see if we can predict rating and delta scores,
using only bags of words as features for our learning model.
"""

data = pandas.read_csv('RTDelta.csv', encoding='latin1')

"""
A simple count vectorizer, which simply uses word frequencies as feature values, is applied to user review texts.
The labels we are trying to predict are, for our first model, the delta scores (avg. critic score - user review score).
"""

data_text = data['Text']
data_features = CountVectorizer(decode_error='replace').fit(data_text).transform(data_text)
data_targets = data['Delta']

"""
Split our featurized data into training and testing, with an 80/20 split
"""

X_train, X_test, y_train, y_test = ttsplit(data_features, data_targets, test_size=0.2, random_state=42)

"""
We'll use gradient tree boosting to learn to predict delta scores from word frequencies in individual user reviews.
"""

model = XGBRegressor(max_depth=20, n_estimators=500, loss='ls', random_state=42, silent=False).fit(X_train, y_train)

"""
After training the learning model on our training set (80% of the data), log the predictions made on the testing set.
"""

predictions = model.predict(X_test)

"""
The learning model performs a regression, and we can evaluate how well the regression explains the testing data using
the r-squared score.  A negative r-squared means the model is actually anti-predictive; an r-squared of 0 means the 
model does no better than simply always guessing the mean value from the training data, and an r-squared of 1 means the
model perfectly predicts the testing data.
"""

print(r2_score(predictions, y_test))

"""
We can use matplotlib to plot the testing data labels against our predictions to visualize how well the model does.
"""

plt.plot(predictions, y_test, 'ro')
plt.plot(range(-5,6), range(-5,6))
plt.show()

"""
Below is the same code, but for a model that predicts user rating instead of delta score.  Comparing the two models
suggests that delta score (critic score - user score) is perhaps more easily predicted by the individual words in the 
user reviews than the user scores themselves.
"""

data_targets = data['Rating']

X_train, X_test, y_train, y_test = ttsplit(data_features, data_targets, test_size=0.2, random_state=42)
model = XGBRegressor(max_depth=20, n_estimators=500, loss='ls', random_state=42, silent=False).fit(X_train, y_train)
predictions = model.predict(X_test)
print(r2_score(predictions, y_test))

plt.plot(predictions, y_test, 'ro')
plt.plot(range(0,6), range(0,6))
plt.show()
