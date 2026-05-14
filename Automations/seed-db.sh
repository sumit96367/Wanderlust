#!/bin/bash

# Configuration
NAMESPACE="wanderlust"
APP_LABEL="mongo"
DB_NAME="wanderlust"
COLLECTION_NAME="posts"
DATA_FILE="../backend/data/sample_posts.json"
POD_TEMP_FILE="/tmp/sample_posts.json"

echo "🔍 Searching for MongoDB pod in namespace '$NAMESPACE'..."

# Get the MongoDB pod name
MONGO_POD=$(kubectl get pods -n $NAMESPACE -l app=$APP_LABEL -o jsonpath='{.items[0].metadata.name}')

if [ -z "$MONGO_POD" ]; then
    echo "❌ Error: Could not find a pod with label app=$APP_LABEL in namespace $NAMESPACE."
    exit 1
fi

echo "✅ Found pod: $MONGO_POD"

# Check if data file exists
if [ ! -f "$DATA_FILE" ]; then
    echo "❌ Error: Data file '$DATA_FILE' not found."
    exit 1
fi

echo "📤 Copying $DATA_FILE to $MONGO_POD:$POD_TEMP_FILE..."
kubectl cp "$DATA_FILE" "$NAMESPACE/$MONGO_POD:$POD_TEMP_FILE"

if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to copy data file to pod."
    exit 1
fi

echo "📥 Importing data into MongoDB..."
# Note: Newer mongo images use 'mongodb' for the db and 'mongosh' for shell, 
# but 'mongoimport' is the standard tool for importing JSON.
kubectl exec -it "$MONGO_POD" -n "$NAMESPACE" -- mongoimport --db "$DB_NAME" --collection "$COLLECTION_NAME" --file "$POD_TEMP_FILE" --jsonArray

if [ $? -eq 0 ]; then
    echo "🎉 Database seeded successfully!"
else
    echo "❌ Error: Data import failed."
    exit 1
fi
