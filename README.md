## Local Setup

The repository should already be hosted on AWS Amplify.
Running locally requires an `amplify_outputs.json` file that is generated in AWS when the
project is deployed.

1. Clone the repository
2. Run `npm install`
3. Navigate to the latest deployment in the AWS Amplify console
	- All apps > project > amplify: Deployments > Deployment 1
4. Switch to the section titled 'Deployed backend resources'
5. Click to download `amplify_outputs.json`