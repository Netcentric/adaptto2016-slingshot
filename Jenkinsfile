node {
	def mavenImg = docker.image('maven:3.3.9-jdk-8'); // https://registry.hub.docker.com/_/maven/
	def slingImg = docker.image("apachesling/sling");

	stage('Mirror') {
		// First make sure the slave has this image. 
		// (For a more PROD-like environment you'd use your own registry)
		mavenImg.pull()
		slingImg.pull()
	}

	  // we're globaly locking this resource (avoid parallelization, as we need to run on a shared docker environment)
	  // if we have distinct slaves we can lock the resource for the concrete environment and have parallel builds on multiple slaves
	  lock('docker-and-scm-workspace') {
	  	def prNumber = env.BRANCH_NAME.replaceAll("PR-","")
		// We are pushing to a private secure Docker registry in this demo.
		// 'docker-registry-login' is the username/password credentials ID as defined in Jenkins Credentials.
		// This is used to authenticate the Docker client to the registry.
		docker.withRegistry('https://localhost/', 'docker-registry-login') {
			stage('Build') {
				sshagent (credentials: ['github_ssh']) {              
					checkout scm
				}
				// The Multibranch plugin already runs on a merged detached branch
				mavenImg.inside("-v /var/jenkins_home/.m2:/root/.m2") {
					sh "mvn clean package" 
				}      
			}

			def sling
			try {
				stage('Integration Tests') {
					parallel(Integration: {
						sling = slingImg.run('')
						mavenImg.inside("--link ${sling.id}:sling -v /var/jenkins_home/.m2:/root/.m2") {
							sh "mvn sling:install -Dsling.url=http://sling:8080/system/console"
							sh 'echo "TODO: image we run some mvn based tests here"'
						}
						sh 'echo "TODO: image we run other tests here"'
					}, StaticAnalysis: { 
						echo 'Mocked static testing'
					})
				}

				// Milestone should be set - we only need to release in case there where no newer builds succeeding
				// but hitting https://issues.jenkins-ci.org/browse/JENKINS-38464
				stage('Release & Baseline') {
					echo "Release & Merge"
					// TODO: run some more release jobs.
					// push merge 					
					sshagent (credentials: ['github_ssh']) {
						// we need to re-attach the HEAD
						// sh "git checkout -b local-tmp;git branch -f master local-tmp;git branch master;git push origin ${env.CHANGE_TARGET};git branch -d local-tmp"
					}
					sh "docker commit ${sling.id} apachesling/sling:latest"
					// make sure reference is really to the latest
					slingImg = docker.image("apachesling/sling")
					// You'd push the updated image to your private registry
					//slingImg.push()
				}  
			} finally {
				// make sure the container is always cleaned up after
				sling.stop()
			}  
		}

		stage('UAT on Reference') {
			parallel(Endurance: {
				echo 'Some endurance testing - load or longlivety'
			}, UserAcceptance: { 
				input 'Confirm User Acceptance'
			})
		}

		stage('Deploy to production') {
			sh "echo 'deploy production'"
		}
	}
}