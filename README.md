# _ss-wordpress
- K.I.S.S. Automated accessible bin scripts for wordpress setup.
- These scripts are meant to be abstracted enough so that they can be used on any WP project.
- ONLY `/bin/sh` POSIX compliant scripts can be used in this repo for portability and restriction to simplicity
## USAGE IN DOCKER
```
ADD https://github.com/penske-media-corp/_ss-wordpress/archive/master.zip /tmp
RUN unzip /tmp/master.zip "*.sh" -d /usr/bin/
```
## USAGE IN DOCKER-COMPOSE
```
 command: >
      sh -c "pmc-run-{php|npm}-ci"
```
OR
```
 command: >
      sh -c "curl -L https://raw.githubusercontent.com/penske-media-corp/_ss-wordpress/*/_ss-*.sh | sh
```
## USAGE VIA CURL
```
curl -L https://raw.githubusercontent.com/penske-media-corp/_ss-wordpress/*/_ss-*.sh | sh
```
## USAGE VIA WGET
```
wget -O - https://raw.githubusercontent.com/penske-media-corp/_ss-wordpress/*/_ss-*.sh | sh
```
## ENVRIONMENT VARIABLES
For the most up to date list of environment variables available for use [see this](https://github.com/penske-media-corp/generator-pmc/generators/docker/templates/wp/.env)

## USAGE VIA GITHOOKS
