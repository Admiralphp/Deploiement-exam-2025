pipeline {
    agent any
    
    environment {
        // Variables Docker Hub (à configurer dans Jenkins Credentials)
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_USERNAME = 'mohamedessid'
        IMAGE_NAME = 'cv-onepage'
        IMAGE_TAG = "${BUILD_NUMBER}"
        
        // Variables Slack (à configurer dans Jenkins Credentials)
        SLACK_CHANNEL = '#devops-notifications'
        SLACK_CREDENTIALS = 'slack-token'
        
        // Variables Git
        GIT_REPO = 'https://github.com/Admiralphp/Deploiement-exam-2025.git'
    }
    
    options {
        // Garder les 10 derniers builds
        buildDiscarder(logRotator(numToKeepStr: '10'))
        
        // Timeout du pipeline à 30 minutes
        timeout(time: 30, unit: 'MINUTES')
        
        // Horodatage dans les logs
        timestamps()
    }
    
    triggers {
        // Scruter le dépôt GitHub toutes les 5 minutes
        pollSCM('H/5 * * * *')
    }
    
    stages {
        stage('Préparation') {
            steps {
                script {
                    echo "=========================================="
                    echo "Pipeline CI/CD - CV One Page"
                    echo "Build #${BUILD_NUMBER}"
                    echo "=========================================="
                }
                
                // Nettoyer le workspace
                cleanWs()
            }
        }
        
        stage('Checkout du code') {
            steps {
                script {
                    echo "Récupération du code depuis GitHub..."
                }
                
                // Clone du dépôt GitHub
                git branch: 'main',
                    url: "${GIT_REPO}"
                
                script {
                    echo "Code récupéré avec succès!"
                    sh 'ls -la'
                }
            }
        }
        
        stage('Vérification des fichiers') {
            steps {
                script {
                    echo "Vérification de la présence des fichiers nécessaires..."
                }
                
                // Vérifier la présence des fichiers
                sh '''
                    if [ ! -f "index.html" ]; then
                        echo "Erreur: index.html introuvable!"
                        exit 1
                    fi
                    
                    if [ ! -f "style.css" ]; then
                        echo "Erreur: style.css introuvable!"
                        exit 1
                    fi
                    
                    if [ ! -f "Dockerfile" ]; then
                        echo "Erreur: Dockerfile introuvable!"
                        exit 1
                    fi
                    
                    echo "Tous les fichiers nécessaires sont présents."
                '''
            }
        }
        
        stage('Build de l\'image Docker') {
            steps {
                script {
                    echo "Construction de l'image Docker..."
                }
                
                // Build de l'image Docker
                sh """
                    docker build \
                        -t ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} \
                        -t ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest \
                        .
                """
                
                script {
                    echo "Image Docker construite avec succès!"
                }
            }
        }
        
        stage('Test de l\'image Docker') {
            steps {
                script {
                    echo "Test de l'image Docker en local..."
                }
                
                // Tester l'image Docker
                sh """
                    # Arrêter et supprimer le conteneur de test s'il existe
                    docker rm -f cv-test || true
                    
                    # Lancer un conteneur de test
                    docker run -d --name cv-test -p 8081:80 ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                    
                    # Attendre que le conteneur soit prêt
                    sleep 5
                    
                    # Tester l'accès au conteneur
                    curl -f http://localhost:8081 || exit 1
                    
                    # Arrêter et supprimer le conteneur de test
                    docker rm -f cv-test
                """
                
                script {
                    echo "Test de l'image réussi!"
                }
            }
        }
        
        stage('Login Docker Hub') {
            steps {
                script {
                    echo "Connexion à Docker Hub..."
                }
                
                // Login sur Docker Hub
                sh """
                    echo \$DOCKERHUB_CREDENTIALS_PSW | docker login -u \$DOCKERHUB_CREDENTIALS_USR --password-stdin
                """
                
                script {
                    echo "Connecté à Docker Hub avec succès!"
                }
            }
        }
        
        stage('Push vers Docker Hub') {
            steps {
                script {
                    echo "Push de l'image vers Docker Hub..."
                }
                
                // Push de l'image vers Docker Hub
                sh """
                    docker push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest
                """
                
                script {
                    echo "Image poussée vers Docker Hub avec succès!"
                }
            }
        }
        
        stage('Nettoyage') {
            steps {
                script {
                    echo "Nettoyage des images Docker locales..."
                }
                
                // Supprimer les images locales pour libérer de l'espace
                sh """
                    docker rmi ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} || true
                    docker system prune -f
                """
                
                script {
                    echo "Nettoyage terminé!"
                }
            }
        }
    }
    
    post {
        success {
            script {
                echo "=========================================="
                echo "Pipeline exécuté avec succès!"
                echo "=========================================="
                echo "Image: ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"
                echo "Docker Hub: https://hub.docker.com/r/${DOCKERHUB_USERNAME}/${IMAGE_NAME}"
                echo "=========================================="
            }
            
            // Notification Slack en cas de succès
            slackSend(
                channel: "${SLACK_CHANNEL}",
                color: 'good',
                message: """
                    ✅ *Pipeline CI/CD - Succès*
                    
                    *Projet:* CV One Page
                    *Build:* #${BUILD_NUMBER}
                    *Statut:* SUCCESS
                    *Durée:* ${currentBuild.durationString}
                    *Image:* ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                    *Lien:* ${BUILD_URL}
                    
                    L'image Docker a été construite et poussée avec succès sur Docker Hub! 🚀
                """.stripIndent(),
                tokenCredentialId: "${SLACK_CREDENTIALS}"
            )
        }
        
        failure {
            script {
                echo "=========================================="
                echo "Pipeline échoué!"
                echo "=========================================="
            }
            
            // Notification Slack en cas d'échec
            slackSend(
                channel: "${SLACK_CHANNEL}",
                color: 'danger',
                message: """
                    ❌ *Pipeline CI/CD - Échec*
                    
                    *Projet:* CV One Page
                    *Build:* #${BUILD_NUMBER}
                    *Statut:* FAILURE
                    *Durée:* ${currentBuild.durationString}
                    *Lien:* ${BUILD_URL}
                    
                    Le pipeline a échoué. Vérifiez les logs pour plus de détails.
                """.stripIndent(),
                tokenCredentialId: "${SLACK_CREDENTIALS}"
            )
        }
        
        always {
            script {
                echo "Pipeline terminé à ${new Date()}"
            }
            
            // Logout de Docker Hub
            sh 'docker logout || true'
        }
    }
}
