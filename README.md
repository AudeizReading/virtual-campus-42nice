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
- The intallations are simplified and decoupled: one defense environment and one
  dev environment.
- The container is built more faster (but is a little more bigger, about 2GB).
  This is done because most of the tools are pre-built on another Docker image
  that I've made and call (you can no longer remove tools from this one).
  - tools included: `gcc g++ make man gdb valgrind vim emacs readline...`
- Firefox is included (at first, I've used it for testing GUI, but I decide to
  let it in, it may be useful, feel free to tell me if not)
- Minilibx is installed and worked. I've tried to install it compliantly on how
  it is described by 42Paris, but maybe I've failed somewhere, so tell me too if it happens. Hope you can play with some So-long, fdf, fractol, Cub3D or MiniRT...
- Readline is intalled. In theory, you can host and run a Minishell...

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

For the moment, it is possible to enter the **relative|absolute** path of the work you
need to look at inside (it won't be a bad idea to set this repo on the same
level of yours, like side by side, you can clone everywhere while you enter a
valid path or noone).

You have the choice to import or no the work that you want to see inside an
Ubuntu environment. Let empty the prompt, when it asks you the path, if you do not want
to import files. Be aware that `../folder` and `../folder/` won't have the same
effect... the first one copies the folder, the second ones copies files into the
folder.

## Inside the container

At the start, you should be placed into the directory named */tmp/corrections* if you have chosen the defense way. Inside it, you should find your mate's repository. Go overthere for beginning the evaluation. Use the Ubuntu commands as `cd` etc.  
Otherwise, you will start at */tmp/dev* or at */usr/src* (the mlx is inside).

Norminette is also installed. `norminette <files> ...` should work.

Also, you should have access to some tools as `gcc` or `g++` or `make`. Feel
free to give any feedback for adding the tools that I might have forgotten.

Mlx is also available. As Firefox is.

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

It is also done quicly, so if you see that I have missed something important,
feel free to contact me by making GH issues, PR, Slack Discord, etc.

Maybe for the v4, I will look at the VSCode side...
