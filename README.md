AWSS3 upload and download file using AWSS3GetPreSignedURLRequest and custom AWSCognitoCredentialsProviderHelper with token and identityId, from API.

**Important** AWSCognito works only with AWSCognitoCredentialsProvider, it will not work if you set AWS Credentials in appdelegate. 
1. Get tokens, auth and other setups from API. 
2. Init singleton AmazonAuth with this fields.
3. Make config: DeveloperAuthenticatedIdentityProvider
4. Now you can upload/download images using PreSignedURL.

Code updated for swift 4. 
