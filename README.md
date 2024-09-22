# netflixoss-eureka

This repository experiments with containerized Netflix's eureka server from the open source project [zerotodocker repo](https://github.com/Netflix-Skunkworks/zerotodocker).

1. Go to [zerotodocker repo](https://github.com/Netflix-Skunkworks/zerotodocker) and choose an image. This repo is using Eureka.

2. From terminal pull image:

	```
	docker pull netflixoss/eureka

	```
	This did not work due to depricated manifest v1 being used. I had to copy dockerfile from repo above and build it locally.

3. Build image manually:
	- Copy dockerfile content from [zerotodocker/eureka](https://github.com/Netflix-Skunkworks/zerotodocker/blob/master/eureka/1.3.1/Dockerfile) 
	- Paste it in my local dockerfile
	- Build it: 
	
		` docker build -t . eureka-image --rm`
	- Changed `MAINTAINER` to `LABEL` and build again
	- Failed at the `wget` command:

		`ERROR: failed to solve: filed to compute cache key: failed to calculate checksum of ref VDYE:LVUO:IAWH:IYEO:BQSU:USHJ:WLYF:FVC3:LZMF:YD3Z:RQ4Q:Y23Z::i06ta8aiuggzfbc9ztkoiz5w2: "/eureka-server-test.properties": not found`

4. Fix the wget command:
	- Ran the wget line command by itself on the terminal, no file was downloaded
	- Looked for the eureka-server artifact in [maven central](https://mvnrepository.com/artifact/com.netflix.eureka/eureka-server) to double-check if it exist, found it and updated the version to latest just in case but `wget` still failed
	- Compared the dockerfile download link http://repo1.maven.org/maven2/com/netflix/eureka/eureka-server/2.0.3/eureka-server-2.0.3.war to the link in the browser https://repo1.maven.org/maven2/com/netflix/eureka/eureka-server/2.0.3/eureka-server-2.0.3.war and found that the dockerfile link was using http while the source had https.
	- Replaced `http` with `https` fixing the issue...
	- Oh wait, no I still got the same error so I ran the line after `wget` on the command line which returned this error: 
	
		`Command 'jar' not found, but can be installed with:
sudo apt install openjdk-17-jdk-headless  # version 17.0.12+7-1ubuntu2~24.04, or`
	- I needed java installed in my local environment to run this line

5. Installing java:
	- Checked the [project github](https://github.com/Netflix/eureka?tab=readme-ov-file)for java version, found 8
	- Downloaded java 8 using: 
	
		```sudo apt install openjdk-8-jdk-headless```
	- Enabled java8 using [jEnv](https://github.com/Fabr1ce/loco-dev-env-setup/tree/main/java#managing-multiple-version-of-java)
	- But that didn't fix the error either because when I decided to upgrade the war file version, I forgot to upgrade it everywhere

6. Upgrade war file version everywhere
	- Created environment variables using ENV and used them accross the dockerfile:
	
	```
	ENV EUREKA_VERSION=2.0.3
	ENV SERVER=eureka-server
	ENV WAR_FILE=$SERVER-$EUREKA_VERSION.war
	
	```
	- Then got another error: `"/eureka-server-test.properties": not found`
	- I forgot to copy all the files from the source [zerotodocker repo](https://github.com/Netflix-Skunkworks/zerotodocker) repo.

7. Added the missing config files from [zerotodocker repo](https://github.com/Netflix-Skunkworks/zerotodocker) repo.
	- Copied the files over manually
	- Somehow the https turned back to http and the wget call is failing again. Changed it back.
	- I decoupled the RUN command with the wget using `WORKDIR` and `ADD`.
	- That fixed it! The image is finally built, successfully 🚀:

		```
		docker build . -t eureka

		```
8. Run the container:
	
	- Run it:

		```
		docker run -p 8080:8080 eureka
	
		```
	- Connect to it:

		```
		curl http://localhost:8080/eureka

		```
	- Connectiong Failed!

9. Troubleshooting connecting to eureka container

	- login into container:
		- find the container id

			```
			docker ps
			```
		- open shell inside container and navigate to the logs

			```
			docker exec -it <container_id> sh
			```

			```
			cd tomcat/logs && cat localhost.2024-09-21.log
			```
		- Found this error in the logs:

			```
			org.apache.catalina.core.StandardContext listenerStart
			SEVERE: Error configuring application listener of class com.netflix.eureka.Jersey3EurekaBootStrap
			```
		- Fixing the error:
			- Reverted to eureka version 1.3.1 and rebuild/re-run and container
			- Running worked! 🚀
			- Logs on the terminal: 
			
				`INFO  com.netflix.discovery.DiscoveryClient:1108 [pool-6-thread-1] [getAndStoreFullRegistry] Getting all instance registry info from the eureka server
				`

				`INFO  com.netflix.discovery.DiscoveryClient:1125 [pool-6-thread-1] [getAndStoreFullRegistry] The response status is 200`

10. Optimize

	Changes made in step 7 introduced additional layers/build steps to the image which increased its size. In order to reduce the size, I re-combined those steps like this.

	| Image Size Before   | Image Size After    |
	|:-------------------:|:-------------------:|
	|       633MB         |       641MB         |


11. Build end-to-end infra with eureka server
