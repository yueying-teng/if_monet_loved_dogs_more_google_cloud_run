# If Monet Loved Dogs More - Google Cloud Run

### This repo contains an app, deployed with [Google Cloud Run](https://cloud.google.com/run/?utm_source=google&utm_medium=cpc&utm_campaign=japac-AU-all-en-dr-bkws-all-pkws-trial-e-dr-1009882&utm_content=text-ad-none-none-DEV_c-CRE_495211807328-ADGP_Hybrid%20%7C%20BKWS%20-%20EXA%20%7C%20Txt%20~%20Compute%20~%20Cloud%20Run_cloud%20run-general%20-%20Products-KWID_43700060418818126-kwd-678836618089&userloc_1009312-network_g&utm_term=KW_google%20cloud%20run&gclid=Cj0KCQjw2NyFBhDoARIsAMtHtZ6iIgQAz9spdOJ2udbn-5mgtR5Vul-A_rqwCOSI4eaZk9-0QMCHJQMaApIeEALw_wcB&gclsrc=aw.ds), that converts a dog photo to an art piece from [Monet](https://en.wikipedia.org/wiki/Claude_Monet). 🖼️

### Sister repos:
- ### [CycleGAN model training](https://github.com/yueying-teng/streamlit_tfserving_if_monet_loved_dogs_more)
- ### [tf serving with streamlit ui locally (docker-compose)](https://github.com/yueying-teng/streamlit_tfserving_if_monet_loved_dogs_more)

### 💻 Play with the app [here](https://monet-tfserving-streamlit.herokuapp.com/).

<br /> 

## ⚙️ Deployment:
### Prerequisites:
- gcloud cli
- Docker 
- google cloud platform account

### Steps:
1. create a new project on google cloud platform
2. authenticate the cli by running `gcloud auth login`
    - it will tell you to set your account, project id, region, ... select from prompt
    - OR run `gcloud config set project PROJECT_ID`
4. Enable the Cloud Build, Cloud Run, Container Registry, and Resource Manager APIs and grant required IAM permissions [here](https://cloud.google.com/build/docs/deploying-builds/deploy-cloud-run#before_you_begin).
4. run `gcloud builds submit` at the root of this project to build and push the containers to the cloud registry, then deploy the service.


### Details:
Since Cloud run does not support multiple containers in the same service as it's allowed in a pod with K8S, a container that runs multiple processes is used. 

[Tini](https://github.com/krallin/tini) is used as the entrypoint of the container to help avoid creating zombie processes.

Note that the number of instances is limited to 1 on Cloud Run regardless of the traffic. This is to make sure Streamlit will show all the images properly without throwing a `MediaFileManager: Missing file` [warning](https://github.com/streamlit/streamlit/issues/1294#issuecomment-755042396).

