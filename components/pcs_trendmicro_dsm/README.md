Trend Micro DSM
---------------

If the destroy fails or for whatever reason trend is torn down manually, you will need to run the below commands to fix up the environment prior to applying

**aws iam delete-server-certificate -server-certificate-name %certificate name%**
**aws iam delete-instance-profile --instance-profile-name %instance-profile-name%**
