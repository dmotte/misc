# joplin-dropbox-setup

TODO intro

## Upload data to Dropbox

TODO start Joplin Desktop in a Docker container

We can run Joplin Desktop in a Docker container using https://github.com/dmotte/docker-xfwd:

```bash
docker build -t img-joplin01:latest - << 'EOF'
FROM docker.io/dmotte/xfwd:latest
RUN apt-get update && apt-get install -y curl libasound2 && \
    curl -fLo /joplin.deb https://github.com/laurent22/joplin/releases/latest/download/Joplin-3.2.13.deb && \
    apt-get install -y /joplin.deb && rm /joplin.deb && rm -rf /var/lib/apt/lists/*
EOF

docker run -d --name=joplin01 -v/tmp/.X11-unix/X0:/opt/xfwd/host.sock:ro -v"${XAUTHORITY:?}:/opt/xfwd/host.xauth:ro" img-joplin01:latest

docker exec -it -{u,eUSER=}mainuser -{eHOME=,w}/home/mainuser joplin01 joplin --no-sandbox
```

TODO clear all the data by using `Delete local data and re-download from sync target` without setting any sync target

TODO create some data from scratch

TODO force push to Dropbox

TODO Note: it's recommended to use Joplin Desktop to create data from scratch because, unlike Joplin Mobile, you can generate clean encrypted data without unwanted notes, attachments, etc. (TODO check if this is correct)

## Download zip backup from Dropbox

TODO download the `Apps/Joplin` Dropbox folder as zip file. In order to do that, head over to the Dropbox web interface, click on the folder's three-dot icon (`More`) and click on `Download`. See screenshot

## Set up Joplin Mobile

TODO Important: download a zip backup of the Dropbox data before proceeding. See related section

TODO clear all the data by manually deleting all the default notes and notebooks, and empty the Trash

TODO setup sync with Dropbox

TODO you will have attachment conflicts after the first sync, because Joplin has some notes and attachments by default. You can just delete them (see screenshots) or maybe you can run the first sync and then reupload the previous content (i.e. entirely replace all the content of the `Apps/Joplin` folder in your Dropbox account with the content of the zip file) and then run the sync again (TODO check if Joplin Mobile doesn't complain after such operation)

## Read zip backup using Joplin Desktop

TODO start Joplin Desktop in a Docker container

TODO clear all the data by using `Delete local data and re-download from sync target` without setting any sync target

TODO set sync target to local filesystem directory

TODO force pull with `Delete local data and re-download from sync target`
