# Init Container to check database connectivity

The module is used to create a docker image
which can be used to check if the database connectivity is successful. 

The image will be build, tagged and pushed to ECR via this script.

```shell
./pushToECR.sh
```
