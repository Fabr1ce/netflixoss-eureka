# Copyright 2014 Netflix, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM netflixoss/tomcat:7.0.64

LABEL maintainer="Netflix Open Source Development <talent@netflix.com>"

ENV VERSION=1.10.18
ENV SERVER=eureka-server
ENV WARFILE=$SERVER-$VERSION.war

RUN echo $SERVER && echo $WARFILE && echo $VERSION

WORKDIR /tomcat/webapps

# RUN cd /tomcat/webapps &&\
RUN mkdir eureka

WORKDIR eureka
  # cd eureka &&\

ADD https://repo1.maven.org/maven2/com/netflix/eureka/$SERVER/$VERSION/$WARFILE .

RUN jar xf $WARFILE
RUN  rm $WARFILE

ADD config.properties /tomcat/webapps/eureka/WEB-INF/classes/config.properties
ADD eureka-client-test.properties /tomcat/webapps/eureka/WEB-INF/classes/eureka-client-test.properties
ADD eureka-server-test.properties /tomcat/webapps/eureka/WEB-INF/classes/eureka-server-test.properties

WORKDIR /

EXPOSE 8080

ENTRYPOINT ["/tomcat/bin/catalina.sh", "run"]

#CMD ["run"]
