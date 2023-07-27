# virtual-campus-42nice

## Prerequesites

- Docker Desktop [ >> HERE <<](https://docs.docker.com/get-docker/). Launch it.
- 42 SSH key && git set up (For obvious safety reasons, it wouldn't be here).

## Installation

```
make install REPO=url-mate-s-repository
```

## Inside the container

At the start, you should be placed into a directory named "corrections". Inside it, you should find your mate's repository. Go overthere for beginning the evaluation. Use the Ubuntu commands as `cd` etc.

Norminette is also installed. `norminette <files> ...` should work.

Also, you should have access to some tools as `gcc` or `g++` or `make`. Feel
free to give any feedback for adding the tools that I might have forgotten.

## Exit of the container

Inside the container:

```
exit
```

## Uninstall

```
make uninstall
```

## Conclusion
This is only a one-shot correction container as it was made quickly. Every
suggestions, ideas etc for improving it are welcome (I've sawn the possibity to
bind it with VSCode, but as I have never deal with it... you know what...).     
PR are open.

## Addendum

### Running GUI apps inside the container

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

If you encounter a trouble with the DISPLAY environment variable, you
should update it (inside the Makefile where `docker run` is) to your workstation's $DISPLAY value or set it to the value :0. Feedback me if it happens.
