pipeline {
    agent any
      environment {
        // Set environment variables for project and cluster
        PROJECT_ID    = 'your-gcp-project-id'
        APP_NAME      = 'discovery-service'
        CLUSTER_ZONE  = 'us-central1-a'         // or your cluster zone/region
        GCLOUD_PATH =  '/Users/rkasprovych/Downloads/google-cloud-sdk/bin'
        DOCKER_PATH =  '/usr/local/bin'
        // ^ Jenkins credential (type "Secret file") for the GCP service account JSON
    }
    stages {

         stage('Build') {
                    steps {
                        sh './mvnw -B -DskipTests clean package'
                    }
                }
         stage('Build docker Image') {
                        steps {
                           sh '$DOCKER_PATH/docker build -t us-central1-docker.pkg.dev/r-level-booking-service-461711/booxiwi-repo/$APP_NAME:v1 --platform linux/amd64 .'

                        }
                    }
          stage('Auth to GCP & GAR') {
                steps {
                        withCredentials([file(credentialsId: 'sa', variable: 'GCLOUD_KEY')]) {
                          sh '''
                            # Activate service-account credentials
                            $GCLOUD_PATH/gcloud auth activate-service-account --key-file="$GCLOUD_KEY" --project="r-level-booking-service-461711"
                            $GCLOUD_PATH/gcloud config set project r-level-booking-service-461711
                            cat $GCLOUD_KEY | $DOCKER_PATH/docker login -u _json_key --password-stdin https://us-central1-docker.pkg.dev
                            $DOCKER_PATH/docker push us-central1-docker.pkg.dev/r-level-booking-service-461711/booxiwi-repo/$APP_NAME:v1
                          '''
                        }
                      }
                    }


    stage('Deploy to cloud run') {
        steps {
           withCredentials([file(credentialsId: 'sa', variable: 'GCLOUD_KEY')]) {
            sh '''
                   # Activate service-account credentials
                   $GCLOUD_PATH/gcloud auth activate-service-account --key-file="$GCLOUD_KEY" --project="r-level-booking-service-461711"
                   $GCLOUD_PATH/gcloud config set project r-level-booking-service-461711

                   $GCLOUD_PATH/gcloud run deploy $APP_NAME \
                     --image="us-central1-docker.pkg.dev/r-level-booking-service-461711/booxiwi-repo/$APP_NAME:v1" \
                     --port=8761 \
                     --platform=managed \
                     --allow-unauthenticated \
                     --concurrency=40 \
                     --memory=512Mi \
                     --region=us-central1 \
                     --timeout=300s
                 '''
            }
        }
    }
  }

}