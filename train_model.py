import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
import joblib

# Load data
data = pd.read_csv('./data/data.log', delimiter=' ')
data['sensor_value'] = data['sensor_value'].astype(int)

# Preprocess data
data['timestamp'] = data.index
X = data[['timestamp']]  # Features (e.g., timestamp)
y = data['sensor_value']  # Target

# Train/test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train model
model = RandomForestRegressor()
model.fit(X_train, y_train)

# Save model
joblib.dump(model, './data/model.pkl')

