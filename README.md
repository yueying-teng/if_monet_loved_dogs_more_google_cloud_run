# If Monet Loved Dogs More - Google Cloud Run

### This repo contains an app, deployed with [Google Cloud Run](https://cloud.google.com/run/?utm_source=google&utm_medium=cpc&utm_campaign=japac-AU-all-en-dr-bkws-all-pkws-trial-e-dr-1009882&utm_content=text-ad-none-none-DEV_c-CRE_495211807328-ADGP_Hybrid%20%7C%20BKWS%20-%20EXA%20%7C%20Txt%20~%20Compute%20~%20Cloud%20Run_cloud%20run-general%20-%20Products-KWID_43700060418818126-kwd-678836618089&userloc_1009312-network_g&utm_term=KW_google%20cloud%20run&gclid=Cj0KCQjw2NyFBhDoARIsAMtHtZ6iIgQAz9spdOJ2udbn-5mgtR5Vul-A_rqwCOSI4eaZk9-0QMCHJQMaApIeEALw_wcB&gclsrc=aw.ds), that converts a dog photo to an art piece from [Monet](https://en.wikipedia.org/wiki/Claude_Monet). 🖼️
### Sister repos:
- ### [CycleGAN model training](https://github.com/yueying-teng/streamlit_tfserving_if_monet_loved_dogs_more)
- ### [tf serving with streamlit ui locally (docker-compose)](https://github.com/yueying-teng/streamlit_tfserving_if_monet_loved_dogs_more)

### Play with the app [here](https://if-monet-loved-dogs-more-xtyx6u2o6a-uc.a.run.app).💻


## Deployment:
### Prerequisites:
- gcloud cli
- google cloud account

### Steps:
1. make a new project on google cloud
2. authenticate the cli by running `gcloud auth login`
    - it will tell you to set your project id, select from prompt
3. OR `gcloud config set project PROJECT_ID`
4. run `gcloud build submit` at the root of this project to build and push the containers the cloud registry
5. run the `gcloud run deploy` chunk from below to deploy the service.


### Details:
Since Cloud run does not support multiple containers in the same service as it's allowed in a pod with K8S, a container that runs multiple processes is used. 

[Tini](https://github.com/krallin/tini) is used as the entrypoint of the container to help avoid creating zombie processes.

The container is built using Cloud Build, by either running 
```
gcloud builds submit
```
or from the [trigger](https://cloud.google.com/build/docs/automating-builds/create-manage-triggers) created using the console, which needs the Dockerfile and other assets to be ready at the source repository.

Then deploy the service either by running 
```
gcloud run deploy if-monet-loved-dogs-more \
--image=gcr.io/$PROJECT_ID/monet_tfserving_streamlit:latest \
--cpu=2 \
--memory=2G \
--timeout=300 \
--max-instances=1 \
--min-instances=1 \
--platform=managed \
--allow-unauthenticated
```
Note that the number of instances is limited to 1 here regardless of the traffic. This is to make sure Streamlit will show all the images properly without throwing a `MediaFileManager: Missing file` [warning](https://github.com/streamlit/streamlit/issues/1294#issuecomment-755042396).