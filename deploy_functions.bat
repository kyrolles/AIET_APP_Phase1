@echo off
echo Deploying Firebase Cloud Functions...
cd functions
npm install
npx firebase deploy --only functions
echo Deployment complete! 