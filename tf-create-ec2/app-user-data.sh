#!/bin/bash

# Set the MongoDB connection string using the database VM private IP
export MONGODB_URI="mongodb://${db_ip}:27017/tictactoe"

# Navigate to the Tic Tac Toe application directory
cd /repo/app

# Start the application in PM2 and assign it the name "app"
pm2 start index.js --name app

# Save the PM2 process list so it can be restored automatically
pm2 save