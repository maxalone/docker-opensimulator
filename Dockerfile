#Name of container: docker-opensimulator
FROM quantumobject/docker-baseimage:18.04
#Based on original Docker file by Angel Rodriguez  "angel@quantumobject.com"
#Updated from mascam64@outlook.it www.tangram.page github.tangram.page
#Opensimulatore rel.0.9.2.1


#to fix problem with /etc/localtime
ENV TZ America/New_York

#Add repository and update the container
#Installation of necessary package/software for this containers...
#nant was remove and added mono build dependence
RUN curl https://download.mono-project.com/repo/xamarin.gpg | apt-key add - \ 
    && echo "deb http://download.mono-project.com/repo/ubuntu bionic main" | tee /etc/apt/sources.list.d/mono-official.list
RUN echo $TZ > /etc/timezone && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q  --no-install-recommends screen mono-complete ca-certificates-mono tzdata \
                    && rm /etc/localtime  \
                    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
                    && dpkg-reconfigure -f noninteractive tzdata \
                    && apt-get clean \
                    && rm -rf /tmp/* /var/tmp/*  \ 
                    && rm -rf /var/lib/apt/lists/*

##Startup scripts  
#Pre-config scrip that needs to be run only when the container runs the first time 
#Setting a flag for not running it again. This is used for setting up the service.
RUN mkdir -p /etc/my_init.d
COPY startup.sh /etc/my_init.d/startup.sh
#Clean file from Windows CRLF
RUN sed -i -e 's/\r$//' /etc/my_init.d/startup.sh
RUN chmod +x /etc/my_init.d/startup.sh

##Adding Deamons to containers
# To add opensim deamon to runit		
RUN mkdir /etc/service/opensim		
COPY opensim.sh /etc/service/opensim/unrun		
RUN chmod +x /etc/service/opensim/unrun

#Pre-config script that needs to be run when container image is created 
#optionally include here additional software that needs to be installed or configured for some service running on the container.
COPY pre-conf.sh /sbin/pre-conf.sh
RUN chmod +x /sbin/pre-conf.sh
RUN sync
#Clean file from Windows CRLF
RUN sed -i -e 's/\r$//' /sbin/pre-conf.sh
RUN /sbin/pre-conf.sh
RUN rm /sbin/pre-conf.sh

#Script to execute after install done and/or to create initial configuration
COPY after_install.sh /sbin/after_install
RUN chmod +x /sbin/after_install

# To allow access from outside of the container  to the container service at these ports
# Need to allow ports access rule at firewall too .  
# Don't forget you need a TCP/UDP port for each Region in the grid!
EXPOSE 9000/tcp
EXPOSE 9000/udp
EXPOSE 9001/tcp
EXPOSE 9001/udp
EXPOSE 9002/tcp
EXPOSE 9002/udp
EXPOSE 9003/tcp
EXPOSE 9003/udp
EXPOSE 9004/tcp
EXPOSE 9005/udp


# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
