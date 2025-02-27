pipeline {
  agent any
  environment {
    GCP_PROJECT = 'cloud-infra-project-1-452021'
    GCP_BUCKET = 'cloudinfra-bucket-1740527626'
  }
  stages {
    stage('Checkout') {
      steps {
        script {
          try {
            git 'https://github.com/Siddeshwar002/cloud-infra-project-1.git'
          } catch (Exception e) {
            echo "ERROR: Failed to checkout code from GitHub. Details: ${e}"
            currentBuild.result = 'FAILURE'
            error("Pipeline failed at Checkout stage.")
          }
        }
      }
    }
    stage('Clear Old Data') {
      steps {
        script {
          try {
            sh """
            # Clear old input and output files (optional)
            gsutil rm -r gs://${GCP_BUCKET}/input/* || true
            gsutil rm -r gs://${GCP_BUCKET}/output/* || true
            """
          } catch (Exception e) {
            echo "WARNING: Failed to clear old data. Details: ${e}"
            // Continue even if clearing fails
          }
        }
      }
    }
    stage('Build Hadoop Job') {
      steps {
        script {
          try {
            sh 'mvn clean package'  // Build the JAR file
          } catch (Exception e) {
            echo "ERROR: Failed to build Hadoop job. Details: ${e}"
            currentBuild.result = 'FAILURE'
            error("Pipeline failed at Build Hadoop Job stage.")
          }
        }
      }
    }
    stage('Upload JAR and Input Files') {
      steps {
        script {
          try {
            sh 'gsutil cp target/WordCount.jar gs://${GCP_BUCKET}/hadoop-jobs/WordCount.jar'  // Upload the new JAR to GCS
            sh 'gsutil cp input/input.txt gs://${GCP_BUCKET}/input/'  // Upload input files to GCS
          } catch (Exception e) {
            echo "ERROR: Failed to upload JAR or input files. Details: ${e}"
            currentBuild.result = 'FAILURE'
            error("Pipeline failed at Upload JAR and Input Files stage.")
          }
        }
      }
    }
    stage('SonarQube Analysis') {
      steps {
        script {
          try {
            withSonarQubeEnv('sonarqube') {
              sh 'mvn clean verify sonar:sonar'
            }
          } catch (Exception e) {
            echo "ERROR: SonarQube analysis failed. Details: ${e}"
            currentBuild.result = 'FAILURE'
            error("Pipeline failed at SonarQube Analysis stage.")
          }
        }
      }
    }
    stage('Deploy to Hadoop') {
      when {
        expression { currentBuild.resultIsBetterOrEqualTo('SUCCESS') }
      }
      steps {
        script {
          try {
            sh """
            gcloud dataproc jobs submit hadoop \
              --cluster=hadoop-cluster \
              --region=us-central1 \
              --jar=gs://${GCP_BUCKET}/hadoop-jobs/WordCount.jar \
              -- \
              gs://${GCP_BUCKET}/input/ \
              gs://${GCP_BUCKET}/output/
            """
          } catch (Exception e) {
            echo "ERROR: Failed to submit Hadoop job. Details: ${e}"
            currentBuild.result = 'FAILURE'
            error("Pipeline failed at Deploy to Hadoop stage.")
          }
        }
      }
    }
  }
  post {
    failure {
      echo "Pipeline failed! Check the logs for details."
      // Add notification logic here (e.g., email, Slack)
    }
    success {
      echo "Pipeline succeeded!"
    }
  }
}
