# Samba-Docker

SMB/CIFS file server, packed into a Docker container.

Samba will write to the mounted volumes using the user and group of the base directory.

## Usage

    docker run -d -p 137:137/udp -p 138:138/udp -p 139:139 -p 445:445 -e "SMB_USER=[..user..]" -e "SMB_PASSWORD=[..password..]" --volumes-from [..include your volumes here..] arthurl/samba-docker [..list of directories to share..]

Real life example---I am running the [`ipython/notebook`](https://registry.hub.docker.com/u/ipython/notebook/) docker container (with container name `ipython`), and I want to allow users to access the `/notebooks` directory via SMB with the username `myuser` and password `mypassword`. I would then execute

    docker run -d -p 137:137/udp -p 138:138/udp -p 139:139 -p 445:445 -e "SMB_USER=myuser" -e "SMB_PASSWORD=mypassword" --volumes-from ipython arthurl/samba-docker /notebooks

iPython should have no problems opening files transferred via this manner, because the file ownership should be correctly set by the script.

## Credits

A good amount of code was copied from [SvenDowideit's dockerfiles repo](https://github.com/SvenDowideit/dockerfiles) (namely the samba [setup script](https://github.com/SvenDowideit/dockerfiles/blob/fb1f29237c1ec76d9d3aeccbd9d390433a6c8865/samba/setup.sh)).
