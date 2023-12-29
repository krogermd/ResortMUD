FROM ubuntu:latest as intermediate

# install git
# Basic update and download needed tools
RUN apt-get -y update
RUN apt-get install -y build-essential
RUN apt-get install -y git
RUN apt-get install -y csh
RUN apt-get install -y net-tools
RUN apt-get install -y telnet

# add credentials on build
ARG SSH_PRIVATE_KEY
RUN mkdir /root/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa

# make sure your domain is accepted
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts

RUN git clone git@bitbucket.org:your-user/your-repo.git

# Clone the resortmud repo and build it
# RUN git clone https://github.com/DikuMUDOmnibus/ResortMUD.git /ResortMUD
RUN mkdir /ResortMUD
ADD . /ResortMUD

RUN make clean -C /ResortMUD/src
RUN make -C /ResortMUD/src


# Create production image
FROM ubuntu:latest

# Copy the compiled assets that we need to run from the builder image
COPY --from=builder /usr/local/lib/libhts.so /usr/local/lib/libhts.so
COPY --from=builder /usr/local/lib/libhts.so.2 /usr/local/lib/libhts.so.2
COPY --from=builder /usr/local/lib/libhts.a /usr/local/lib/libhts.a
COPY --from=builder /usr/local/bin/htsfile /usr/local/bin/htsfile
COPY --from=builder /usr/local/bin/tabix /usr/local/bin/tabix
COPY --from=builder /usr/local/bin/bgzip /usr/local/bin/bgzip

WORKDIR /app
COPY myapp/ .


EXPOSE 4100

ENTRYPOINT /ResortMUD/src/rmstart

