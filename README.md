# Docker Permissions

This is a quick example to test the suggestion at [this post](https://vsupalov.com/docker-shared-permissions/),
namely we want to build a container with a particular user and group id,
and then run it. We will bind a directory in the present working directory
to write file to, and check that they are owned by the building user.

The caveat to this approach is that you would likely have to build the
container each time for a new user id.

## Docker

### 1. Build the container

The first step is to build the container, and we will map our group and user id:

```bash
$ docker build -t docker-permissions --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) .
```

### 2. Run the container

Let's now run an interactive shell in the container, and check who we are!
We will mount a local directory to test writing files.

```bash
$ mkdir -p flies
$ docker run -it --rm --mount "type=bind,src=$(pwd)/files,dst=/opt/files" --workdir /opt/files docker-permissions bash
```

Let's check who we are!

```bash
$ whoami
squidward

$ echo $(id -u)
1000

$ echo $(id -g)
1000
```

If the user has a similar host setup and are the default first user on their system,
then you could be in luck because [Linux automatically assigns this id](https://www.redhat.com/sysadmin/user-account-gid-uid).

### 3. Create files

Next let's try creating files in the container to see what happens.

```bash
$ touch squidwards-file.txt
$ mkdir squidwards-folder
```

And peek at permissions:

```bash
$ ls -l
total 4
-rw-r--r-- 1 squidward squidward    0 Feb 12 18:18 squidwards-file.txt
drwxr-xr-x 2 squidward squidward 4096 Feb 12 18:19 squidwards-folder
```

And now exit the container:

```bash
$ exit
```

### 4. Check host permissions

Do the same to check permissions on the mounted folder, do they belong to my user (my
username let's say is dinosaur):

```bash
$ ls -l files/
total 4
-rw-r--r-- 1 dinosaur dinosaur    0 Feb 12 11:18 squidwards-file.txt
drwxr-xr-x 2 dinosaur dinosaur 4096 Feb 12 11:19 squidwards-folder
```

Success! I can delete or otherwise interact with these files now without
getting a "Permission denied."

## Docker Compose

Let's say we have a more robust application, and want to do the above with docker compose.
You can use the [docker-compose.yml](docker-compose.yml) file included and then
build the container providing the group and user id:

```bash
$ docker-compose build --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)
$ docker-compose up -d
Creating network "docker-permissions_default" with the default driver
Creating docker-permissions_permissions_1 ... done
```

Check that it's running ok:

```bash
$ docker-compose ps
              Name                  Command    State   Ports
------------------------------------------------------------
docker-permissions_permissions_1   /bin/bash   Up           
```

And then shell into the container to see if the files are still owned by
squidward.

```bash
$ ls -l .
total 4
-rw-r--r-- 1 squidward squidward    0 Feb 12 18:21 squidwards-file.txt
drwxr-xr-x 2 squidward squidward 4096 Feb 12 18:19 squidwards-folder
```

Seems to work the same!
