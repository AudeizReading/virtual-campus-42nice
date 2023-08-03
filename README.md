# virtual-campus-42nice V3

## Prerequesites

- **Docker Desktop** [ >> HERE <<](https://docs.docker.com/get-docker/). Launch it.
- **42 SSH key** && **git** set up (For obvious safety reasons, it wouldn't be here).
- **X server** (needed for running GUI applications from the container into your own workstation)

### X Server Installation

You need an X server on your workstation before running the container.
As it is too much platform specific, it is better that you add it by your own.

#### Procedure for MacOSX:

* Install XQuartz :  
    `brew install --cask xquartz`
* Start XQuartz :  
    `open -a XQuartz`
* Open the **XQuartz preferences** panel (near the apple menu, on top left), 
    - select the **Security** tab 
    - enable **Allow connections from network clients**.
* Restart your workstation
* Relaunch XQuartz, if it is not done automatically.
* Check if XQuartz is running :  
    `ps aux | grep Xquartz`  
    Ensure that you find a line similar to this : `.../opt/X11/bin/Xquartz :0 -listen tcp...`.
* Allow X11 forwarding  :   
    `xhost +localhost` (this one has to be executed
  after each restart of X11)

Thanks to [Sorny's explanations](https://gist.github.com/sorny/969fe55d85c9b0035b0109a31cbcb088)

#### Procedure for Windows

As I am not a Windows user anymore, I can only publish tips that I have found on
how to install an X server for Windows. I cannot confirm if it works. The flavor seems
to be similar but I can not confirm this.  

[Lancer des applications X11 sous Ubuntu Bash de Windows 10](https://www.piradix.com/article/lancer-des-applications-x11-sous-ubuntu-bash-de-windows-10)  
[Run Linux/X11 apps in Docker and display on a Mac OS X desktop](https://techsparx.com/software-development/docker/display-x11-apps.html)  
[VcXsrv nous permet d'utiliser des applications Linux avec une interface utilisateur dans Windows 10](https://ubunlog.com/fr/vcxsrv-nous-permet-d'utiliser-des-applications-Linux-avec-une-interface-utilisateur-dans-Windows-10/)  
[Windows 10’s Bash shell can run graphical Linux applications with this trick
](https://www.pcworld.com/article/420529/windows-10s-bash-shell-can-run-graphical-linux-applications-with-this-trick.html)  

If you encounter a trouble with the **DISPLAY** environment variable, you
should update it (inside the **Makefile** where rule is `launch`) to your workstation's **$DISPLAY** value or set it to the value **:0**. Feedback me if it happens.

## New Features
- You can now work in real-time on your project. Just provide the path and it
  would be bound to the container. If you do not provide it, a dev container will
  be built without the capability to update in real-time, on your host, your work. **Not available on the defense container.**
- The 42's header vim plugin is now installed and works well. You have just to
  enter your 42's login (otherwise it will use marvin as login). By
  default the address mail related is by default ended with `[at]student-42nice[dot]fr`
- You can now start a container into a container (in theory choose firefox opt +
  docker opt for being able to run an inception container). For an overview of
  the process in action, I recommend this blog post that helped me a lot [Docker in Docker](https://blog.hiebl.cc/posts/gitlab-runner-docker-in-docker/).

## Previous Features

- The intallations are simplified and decoupled: one defense environment and one
  dev environment.
- The container is built more faster (but is a little more bigger, about 1.7GB).
  This is done because most of the tools are pre-built on another Docker image
  that I've made and call (you can no longer remove tools from this one but you
  can have an overview overthere [pre-built Ubuntu image](https://hub.docker.com/repository/docker/audeizreading/virtual-campus-42nice/general)).
  - tools included: 
    - `gcc`
    - `g++`
    - `make`
    - `man`
    - `gdb`
    - `valgrind`
    - `vim`
    - `emacs`
    - `readline`
    - `curl`
    - `wget`
- You have the choice to install or not Firefox, you will be prompted for. The
  consequence is that the image is a bit smaller (1.44GB)
- Minilibx is installed and worked. I've tried to install it compliantly on how
  it is described by 42Paris, but maybe I've failed somewhere, so tell me too if it happens. Hope you can play with some So-long, fdf, fractol, Cub3D or MiniRT...
- Readline is intalled. In theory, you can host and run a Minishell...

## TO-DO Features
- Being able to work on web projects (node.js, npm, yarn...)
- Being able to emulate Android mobile projects (do not even think about
  emulating iOS projects on this container, unless someone has the solution for...)
- Being able tu run outCC projects.
- Isolate services into their own container.

Update from your side, on your workstation, this repo regularly *- until this is not the final stable version, features would be adjusted frequently as this README*.

```
git pull origin main
```

## Installation

### Creating a defense container

As some mates are concerning about cheating, I've made a container that git
clone the url asked by prompt, copy the work directly into the
containers and directly delete it at the exit of the container. It is still
possible to cheat (if you know how to do...), but it would be a kind harder than
if you can access directly to your mate's work.

```
make defense
```

You will be prompted for the repo's url, provide it for beginning the defense.

### Creating a container for development

```
make install
```

You just may want to know if your project passes 42's standards. Great news, it
is now available.

And you can even know if your work passes 42'standard in **real-time**. That means
that, after connecting your work folder, you can type your code base from your
workstation, and see the result into the container in real-time. You do not have
to re-build this container each time you make a change. You can provide whatever
regular path for binding to the container like `$HOME/my-work` or `~/my-work` or
`/usr/home/login/my-work` or `../my-work`.

## Inside the container

At the start, you should be placed into the directory named */tmp/corrections* if you have chosen the defense way. Inside it, you should find your mate's repository. Go overthere for beginning the evaluation. Use the Ubuntu commands as `cd` etc.  
Otherwise, you will start at */tmp/dev* or */tmp/dev/your-project-name* or at */usr/src*.

Also, you should have access to some tools as `gcc` or `g++` or `make`. Feel
free to give any feedback for adding the tools that I might have forgotten.

Installed 42's tools:
+ Minilibx (42Paris)
+ Norminette

Optionnal tools: (choose **y** when you are prompted for)
+ Firefox
+ 42's vim header (`:Stdheader` in vim command mode)
+ Docker
+ Node.js
+ Android Emulator

### Test Norminette

You can test your compliance to Norminette by just running the program
everywhere you are inside the container: 

```
norminette [<file>...]
```

### Test MLX

We are still inside the container. Enter this for running the mlx tests provided
by 42network

```
cd /usr/src/mlx/test 
./run_tests.sh
```

A demo should be run after this.

### Test Firefox

Still into container, if you have enter "y" when it is asked to you, you have
access to Firefox with GUI. Enter:

```
firefox
```

A Firefox GUI should run.

Do not worry if you get the following message inside the container:
```
[GFX1-]: glxtest: libpci missing
[GFX1-]: glxtest: libEGL missing
[GFX1-]: glxtest: libGL.so.1 missing
[GFX1-]: No GPUs detected via PCI
```

Wait for few seconds, you will be able to browse soon.

### Test Docker

```
docker run hello-world
```

You should see a new container appearing into your Docker Desktop app. Manage
directly the container for stopping and removing it.

## Exit of the container

Inside the container:

```
exit
```

## Reuse the container

You cannot (yet) add files, but you can re-enter into the container after having
exiting it.

```
make run
```

## Uninstall

```
make uninstall
```

## VSCode

There will not a v4 for VSCode, because it exists an extension that make you
able to work in real-time into this container from your workstation. I am not a VSCode user but the
installation does not seem very complicated, just follow the instructions, test
and retry if it does not work.

I let you take a look at the offical documentation :
+ [Containers overview](https://code.visualstudio.com/docs/containers/overview)
+ [Remote overview](https://code.visualstudio.com/docs/remote/remote-overview)
+ [Devcontainers](https://code.visualstudio.com/docs/devcontainers/containers)

## Conclusion

If you are looking for the old version v1 without GUI support (the one-shot correction):

```
git clone git@github.com:AudeizReading/virtual-campus-42nice.git
git checkout -b v1
git pull origin v1
```

If all happens right, you should retrieve the v1 version , and the corresponding commands are detailed into the old README.md.

I guess (and hope), then with this v3, almost all common core projects are
accessible.

It is also done quickly, so if you see that I have missed something important,
feel free to contact me by making GH issues, PR, Slack Discord, etc.
