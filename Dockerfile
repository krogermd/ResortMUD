FROM ubuntu:latest as intermediate

# install git
# Basic update and download needed tools
RUN apt-get -y update
RUN apt-get install -y build-essential
RUN apt-get install -y git
RUN apt-get install -y csh
RUN apt-get install -y net-tools
RUN apt-get install -y telnet

# Clone the resortmud repo and build it
RUN git clone https://github.com/krogermd/ResortMUD.git /ResortMUD

WORKDIR /ResortMUD

RUN git checkout build-cleanup

RUN make clean -C /ResortMUD/src
RUN make -C /ResortMUD/src

# Probably need to make directories in the application but it's not there now.  This allows players to be made
# with names starting with any alphabet letter.
RUN for i in {a..z}; do mkdir /ResortMUD/player/$i; done

# Create production image
# Doing multi-stage build because in the future I may place the repo behind password protection and will need to copy 
# a private key in the first stage etc. in order to keep the key out of the final image or history.
FROM ubuntu:latest

run mkdir /ResortMUD

# Copy the compiled assets that we need to run from the builder image
COPY --from=intermediate /ResortMUD /ResortMUD

EXPOSE 4100

ENTRYPOINT /ResortMUD/src/rmstart
