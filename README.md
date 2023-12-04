# virtual-campus-42nice

Docker container emulating a 42 virtual campus with the minimal requirements needed for developping and defending projects.

Only allowed for the **42 Nice** campus. *This is not an official 42 tool.*

## Summary

<details><summary><b>Installation</b></summary>

- [Installation](#installation)
    1. [Prerequesites](#prerequesites)
        1. [X Server Installation](#x-server-installation)
    1. [Download Container](#download-container)
        1. [Update Container](#update)
    1. [Defense container](#creating-a-defense-container)
    1. [Development container](#creating-a-development-container)

</details>

<details><summary><b>Utilisation</b></summary>

- [Utilisation](#utilisation)
    1. [Compilers](#compilers)
    1. [Norminette](#norminette)
    1. [MLX](#mlx)
    1. [Readline](#readline)
    1. [Firefox](#firefox)
    1. [Docker](#docker)
    1. [OpenGL](#opengl)
    1. [RC Files](#rcfiles)
    1. [Exit container](#exit)
    1. [Reenter container](#rerun)
    1. [Uninstall container](#uninstall)

</details>

<details><summary><b>Miscellaneous</b></summary>

- [Miscellaneous](#miscellaneous)
    1. [Last Updates](#last-updates)
    1. [Last Version](#last-version)
    1. [Last Changes](#last-changes)
    1. [Preinstalled Tools](#tools)
    1. [How to Contribute](#how-to-contribute)
        1. [Discussion](#discussion)
        1. [Issues](#issues)
        1. [Pull Requests](#pull-requests)
    1. [License](#license)
    1. [Authors](#authors)

</details>

## Installation

### Prerequesites

- **Docker Desktop** [ >> HERE <<](https://docs.docker.com/get-docker/). Launch it.
- **42 SSH key** && **git** set up on your personal workstation.
- **X server** (needed for running GUI applications from the container into your own workstation)
- **bash**

> <picture>
>   <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/light-theme/warning.svg">
>   <img alt="Warning" src="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/dark-theme/warning.svg">
> </picture><br>
>
> If you are a MacOSX Silicon chip user, you may have troubles with Docker. Take care
> to install the `arm64` version of the Docker Desktop.  
> If you are still in trouble, try to apply first what is explained [>>> HERE <<<](https://collabnix.com/warning-the-requested-images-platform-linux-amd64-does-not-match-the-detected-host-platform-linux-arm64-v8/), then open
> an issue, if it does not still work, we will see what is possible to do.

> <picture>
>   <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/light-theme/info.svg">
>   <img alt="Info" src="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/dark-theme/info.svg">
> </picture><br>
>
> Info (contribution de @louchebem06)
>
> Recommandation pour les utilisateurs Linux et macOS
> Si vous utilisez Linux ou macOS, vous pouvez envisager une alternative à Docker Desktop pour gérer vos conteneurs. Une excellente option est Orbstack, que vous pourriez préférer en raison de sa faible utilisation des ressources système.
> 
> Orbstack offre de nombreux avantages par rapport à Docker Desktop en termes d'efficacité et de légèreté, ce qui peut améliorer considérablement les performances de votre système. Cependant, veuillez noter qu'Orbstack n'est pas compatible avec Windows, y compris Windows Subsystem for Linux (WSL).
> 
> Si vous êtes sur Linux ou macOS, vous pouvez suivre ces étapes pour utiliser Orbstack :
> 
> Visitez le site web d'Orbstack à https://orbstack.dev/.
> Suivez les instructions d'installation spécifiques à votre système d'exploitation pour obtenir Orbstack.
> Une fois Orbstack installé, vous pouvez l'utiliser pour gérer vos conteneurs de manière plus efficace et économiser des ressources système.
> N'hésitez pas à explorer Orbstack comme une alternative à Docker Desktop si vous êtes sur Linux ou macOS. Cela peut améliorer votre expérience de développement et de gestion de conteneurs tout en préservant les ressources de votre système.

#### X Server Installation

You need an X server on your workstation before running the container.
As it is too much platform specific, it is better that you add it by your own.

<details><summary><b>MacOSX</b></summary>

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

</details>

<details><summary><b>Windows</b></summary>

##### Procedure for Windows

As I am not a Windows user anymore, I can only publish tips that I have found on
how to install an X server for Windows. I cannot confirm if it works. The flavor seems
to be similar but I can not confirm this.  

* [Lancer des applications X11 sous Ubuntu Bash de Windows 10](https://www.piradix.com/article/lancer-des-applications-x11-sous-ubuntu-bash-de-windows-10)  
* [Run Linux/X11 apps in Docker and display on a Mac OS X desktop](https://techsparx.com/software-development/docker/display-x11-apps.html)  
* [VcXsrv nous permet d'utiliser des applications Linux avec une interface utilisateur dans Windows 10](https://ubunlog.com/fr/vcxsrv-nous-permet-d'utiliser-des-applications-Linux-avec-une-interface-utilisateur-dans-Windows-10/)  
* [Windows 10’s Bash shell can run graphical Linux applications with this trick
](https://www.pcworld.com/article/420529/windows-10s-bash-shell-can-run-graphical-linux-applications-with-this-trick.html)  

If you encounter a trouble with the **DISPLAY** environment variable, you
should update it (inside the **Makefile** where rule is `launch`) to your workstation's **$DISPLAY** value or set it to the value **:0**. Feedback me if it happens.

*You can now use the container if you are on Windows. If not, contact me.*

</details>

### Download Container

```bash
git clone git@github.com:AudeizReading/virtual-campus-42nice.git
```

<details id="update"><summary><b>Update Container</b> </summary>

**Update from your side, on your workstation, this repo regularly** _- until this is not the final stable version, features would be adjusted frequently as this README_.

```bash
git pull origin main
```

</details>

### Starting installer

According to which container you will install, it will still be necessary to run
the installer. This one needs to be executed with `bash` shell.

> <picture>
>   <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/light-theme/warning.svg">
>   <img alt="Warning" src="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/dark-theme/warning.svg">
> </picture><br>
>
> **Ubuntu** users may encounter troubles if the script installer is executed with the default
shell `Makefile` use, the `sh` shell.  
> If you got an error of the kind of *`error: bad read -n user input` (this is not exactly the error sentence!)*, this is what I talk about.  
> First, check you have the lastest version of this project [>>> HERE <<<](#update).  
> Then open an issue with a detailed summary of your error, and the time I may
> care of it, please manually run the installer script with `bash` or do
> otherwise.

The installer will always ask you if you need some optional features. This
optional features are for the now:

- Firefox,
- Docker,
- Node.js,
- 42's header (only for dev container):  
You will be asked for your 42's login (8 characters max).  
The address mail related is by default ended with `[at]student[dot]42nice[dot]fr`.
- Linking your own `.bashrc` or `.vimrc` file

You can safely type `n` if you do not want any of them.

> <picture>
>   <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/light-theme/warning.svg">
>   <img alt="Warning" src="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/dark-theme/warning.svg">
> </picture><br>
>
> Only one container of each type can be made at the same time. You can open a dev
> container and a defense container at the same time, but never 2 defense
> containers or 2 dev containers at once.

#### Creating a defense container

```bash
make defense
```

<details open><summary><b>Guidelines</b></summary>

You will be prompted for the repository's url, provide it for beginning the defense.

The defender's repository is cloned outside the container and is pasted into it.  
That's why your git's credentials are never asked.

You should be placed at **/tmp/corrections/** at the opening, directly into the defender
folder, you just have to do the defense.

> <picture>
>   <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/light-theme/solution.svg">
>   <img alt="Solution" src="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/dark-theme/solution.svg">
> </picture><br>
>
> You may need to download some files, as it could be required by the scale to
test the project with mandatory files provided on the defense page.   
The only
possible solution, is to download files from the defense
container with:
> ```bash
> curl 'https://cdn.intra.42.fr/your/needed/file1' -o file 'https://cdn.intra.42.fr/your/needed/file2' -o file2...
> ```

Be vigilant by exiting a defense container, it will be entirely destroyed from
your workstation, it is intentional.

</details>

#### Creating a development container

```bash
make install
```

<details open><summary><b>Guidelines</b></summary>

You may provide any regular path as long as it is valid, absolute path, relative
path, path with variables, etc.

> <picture>
>   <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/light-theme/note.svg">
>   <img alt="Note" src="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/dark-theme/note.svg">
> </picture><br>
>
>
> You should be placed at **/tmp/dev/your-folder-name** at the opening of the container.   
If you do not provide a valid path, then, you may start at **/tmp/dev** or **/usr/src**.  
*You can not, yet, begin a project from the container, you will lose it at the
exiting of the container.*
>
> A next feature may let you create a new project or exit the container if it was a
> typing error.  

With this container you can develop in real-time an existing project.  
The path provided at the installation let your folder been mounted to the container.   
Stay on your
favorite code editor, on your workstation, and see directly upgrades been applied into
the container.


If you need to push your progress, only your workstation is bound
to your SSH credentials.   
You cannot update your git repository from the
container. 

</details>

## Utilisation

### Current Usage

You are in an Ubuntu 20.04 environment. You have access to all the builtins
provided by default and other tools listed below. See also the [Tools
section](#tools).

No `sudo` is configured. As its vocation is not to be persistent, you are
`root` into the container, *albeit this is a bad practice to not configure
specific users*.

You can `apt-get` a specific package, but it won't be kept at the deleting of
the container. Contact me for making it persistent.

<details id="compilers"><summary><b>Compilers (all)</b></summary>

Clang and Clang++ are aliased under `gcc` and `g++` as 42 requirements
stipulate.  
You can obtain the confirmation with:
```bash
type gcc
```

If you need to use the real gcc compilers use their `\` versions: `\gcc`, `\gpp`, `\g++`

</details>

<details id="norminette"><summary><b>Norminette (all)</b></summary>

You can test your compliance to Norminette by just running the program
everywhere you are inside the container: 

```bash
norminette [<file>...]
```

</details>

<details id="mlx"><summary><b>MLX (all)</b></summary>

We are still inside the container. Enter this for running the mlx tests provided
by 42network

```bash
cd /usr/src/mlx/test 
./run_tests.sh
```

A demo should be run after this.

</details>

<details id="readline"><summary><b>Readline (all)</b></summary>

GNU readline is installed and works well if you follow these few steps:

1. Always include `<stdio.h>` header before `<readline/readline.h>` and
   `<readline/history.h>`.
2. Always include your lib informations after your source files as following:
   `gcc -Wall -Werror -Wextra source_files -lreadline -L /usr/lib/x86_64-linux-gnu/ -I /usr/include/readline
   -o your_output_file`  
   Your source files (`main.c` or `main.o`) must ALWAYS, in a Linux environment,
   be before your librairies linkage. The executable or the objects files
   generated through `-o` has ALWAYS to be at the end of your instruction.  
   Be kind to also apply `-W` options at the assembly step, when you generate
   object files with `gcc -c`.

</details>

<details id="firefox"><summary><b>Firefox (all)</b></summary>

Still into container, if you have enter "y" when it is asked to you, you have
access to Firefox with GUI. Enter:

```bash
firefox
```

A Firefox GUI should run.

Do not worry if you get the following message inside the container:
```bash
[GFX1-]: glxtest: libpci missing
[GFX1-]: glxtest: libEGL missing
[GFX1-]: glxtest: libGL.so.1 missing
[GFX1-]: No GPUs detected via PCI
```

Wait for few seconds, you will be able to browse soon.

</details>

<details id="docker"><summary><b>Docker (all)</b></summary>

```bash
docker run hello-world
```

You can now start a container into a container (in theory choose firefox opt +
  docker opt for being able to run an inception container). For an overview of
  the process in action, I recommend this blog post that helped me a lot [Docker in Docker](https://blog.hiebl.cc/posts/gitlab-runner-docker-in-docker/).

You should see a new container appearing into your Docker Desktop app. Manage
directly the container for stopping and removing it.

</details>

<details id="opengl"><summary><b>OpenGL (all)</b></summary>

> <picture>
>   <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/light-theme/warning.svg">
>   <img alt="Warning" src="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/dark-theme/warning.svg">
> </picture><br>
> 
> The only attempt to test this feature has been done under **MacOSX**. I am
not sure another platform will connect to the X server correctly. Open an issue
if it happens.
>
> The use of **OpenGL** is **GPU** related. That means if your GPU can not support
> the prerequesites needed by OpenGL, it never will. The only solution for, is to change the GPU...
>
> There is also a limitation for the MacOSX Host users. As the [documentation](https://www.khronos.org/opengl/wiki/OpenGL_Context) mentionned, there is no way to get access to features after OpenGL 2.1. No need to say that it is the only version I was able to install through the container. Indeed, this is OpenGL 1.4, with max capabilities to 2.1. `mesa` is under version 21.

You can test the well installation by typing this command: 

```bash
glxgears
```

A window should open, indicating OpenGL is usable from the container.

You can compile your program with the follwing commands:

```bash
g++ main.cpp -lglut -lGLU -lGL -o firstOpenGlApp
```

For having a little ready-made exemple to see, compile this code snippet

```c++
#include <GL/glut.h>

void displayMe(void)
{
    glClear(GL_COLOR_BUFFER_BIT);
    glBegin(GL_POLYGON);
        glVertex3f(0.5, 0.0, 0.5);
        glVertex3f(0.5, 0.0, 0.0);
        glVertex3f(0.0, 0.5, 0.0);
        glVertex3f(0.0, 0.0, 0.5);
    glEnd();
    glFlush();
}

int main(int argc, char** argv)
{
    	glutInit(&argc, argv);
    	glutInitDisplayMode(GLUT_SINGLE);
    	glutInitWindowSize(400, 300);
    	glutInitWindowPosition(100, 100);
    	glutCreateWindow("Hello world!");
    	glutDisplayFunc(displayMe);
    	glutMainLoop();
    	return 0;
}
```

For getting the OpenGL Version you have been lucky to install:

```bash
glxinfo | grep "OpenGL version"
```

Interesting reading: [Archive OpenGL MACOSX](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/OpenGL-MacProgGuide/opengl_pg_concepts/opengl_pg_concepts.html#//apple_ref/doc/uid/TP40001987-CH208-SW1)  


</details>

<details id="rcfiles"><summary><b>RC Files (all)</b></summary>

For the moment, no user are really created stricto sensus. No need to say, that is a bad practice, but as the purpose of this tool is only for developping and defending projects, I consider it is not an issue.

So as no user is made, it is a bit tricky to configure slightly your rc container environment files. Then, they are set globally (a second very bad practice).

You may find them at this place:

```bash
cat /etc/vim/vimrc.local
cat /etc/bash.bashrc
```

You can now also link two of your own rc files, it will be asked if you want to do that:

- `$HOME/.vimrc` *(from your $HOME environment)*
- `$HOME/.bashrc` *(from your $HOME environment)*

It is still a bit experimental, so do not hesitate to feed back if something not expected happens.

</details>

<details id="exit"><summary><b>Exit container (all)</b></summary>

Inside the container:

```bash
exit
```

</details>

<details id="rerun"><summary><b>Run container after exiting (dev)</b></summary>

You cannot (yet) add files, but you can reenter into the container after having
exited it. 

If you have already uninstalled the container, it is too late, you
shall recreate a new environment [Installation](#starting-installer).

```bash
make run
```

</details>

<details id="uninstall"><summary><b>Uninstall container (dev)</b></summary>

Only available on the development container.

After exiting the container:

```bash
make uninstall
```

</details>

### Tools that won't never been installed into container

<details><summary><b>VSCode</b> </summary>

It exists an extension that make you
able to work in real-time into this container from your workstation.  

I am not a VSCode user but the
installation does not seem very complicated, just follow the instructions, test
and retry if it does not work.

I let you take a look at the offical documentation :
+ [Containers overview](https://code.visualstudio.com/docs/containers/overview)
+ [Remote overview](https://code.visualstudio.com/docs/remote/remote-overview)
+ [Devcontainers](https://code.visualstudio.com/docs/devcontainers/containers)

</details>

<details><summary><b>Android Emulator</b> </summary>

Some solutions exist but only if the host workstation can handle **KVM** and/or
virtualization. As it is **CPU** related, if your workstation can not, it can not
work. I have reached the Android Studio installation stage, but the emulator was
not available for me, only the IDE, through X11 server.

If you need such support, my advice is to install an emulator or an IDE as
Android Studio, directly on your workstation. In theory, if the app launches and
works from your workstation by the emulator, there is no doubt that it can be launched on every
Android device, whatever OS platform it was coded on. You can also use your
Android phone as launcher (but I would not recommend that).

</details>

## Miscellaneous

### Last Updates

If you have downloaded the virtual-campus before these dates following, please
update it [>>> HERE <<<](#update). It might not work with the version you've
owned.
- 10th September 2023.

<details id="calendar"><summary><b>Calendar of previous changes</b></summary>

- 4th December 2023.
- 9th September 2023.
- 8th September 2023.
- 28th August 2023.
- 18th August 2023.
- 06th August 2023.

</details>

#### Last version

We are on the v6.1.5 version of the project. Tags are coming soon.

#### Last Changes
 
> <picture>
>   <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/light-theme/info.svg">
>   <img alt="Info" src="https://raw.githubusercontent.com/Mqxx/GitHub-Markdown/main/blockquotes/badge/dark-theme/info.svg">
> </picture><br>
>
> - Detects if the OS is Windows and set also the XServer connection to (slight different from Mac OS X, especially the DISPLAY variable)
> - Fix bug blocking install of OpenGL
> - A confirmation is now asked for the 42 login: possible to resend a new one.
> - Possible to link the .bashrc or .vimrc of the user if needed
> - Fix bugs norminette, install opengl, node.js 18, bugs X11, remove sudo rights
> - Integrating OpenGL. / fix bugs
> - Integrating better checks for invalid paths (we still can not create new
>   work directory from container). You can now quit if you were mistaken
> - Check for sudo rights
> - Typo fix
> - Check if Docker is running
> - Integrating Pull Requests related to xhost execution and typos fixs **#3**.  
> - Integrating Pull Requests related to bash execution **#1** and **#2**.  

### Preinstalled Tools [Docker Ubuntu 20.04](https://hub.docker.com/repository/docker/audeizreading/virtual-campus-42nice/general)

<details id="tools"><summary><b>Tools (all)</b></summary>

| DevTools | Net Tools | Utils Tools | Others Tools |
|--------|-|-|-|
|clang-12|curl|man|x11 *(-utils, -apps, -common, proto-dev, vnc)*|
|clang++-12|wget|vim|xorg|
|nasm|nmap|emacs|xdotool|
|gdb|netcat|unzip|libxext-dev|
|valgrind|siege|[moreutils](https://packages.ubuntu.com/focal/moreutils) *(perl...)*|libbsd-dev|
|readline-common|netcat|||
|libreadline8|[net-tools](https://net-tools.sourceforge.io/) *(netstat, arp, ifconfig, hostname...)*|||
|libreadline-dev||||
|[minilibx 42Paris](https://github.com/42Paris/minilibx-linux)||||
|[norminette 42School](https://github.com/42School/norminette)||||
|python 3.11||||
|pip3||||
|matplotlib||||
|[software-properties-common](https://packages.ubuntu.com/focal/software-properties-common)||||
|[build-essential](https://packages.ubuntu.com/focal/build-essential) *(libc6, make, gcc, g++)*||||

The base image is about **2.52GB**. This base is pre-built. Be aware of this, when you add optional features. 

You can look at this image at this link : [Docker Ubuntu 20.04](https://hub.docker.com/repository/docker/audeizreading/virtual-campus-42nice/general).

</details>

### How To Contribute

Every idea, suggestion, issue, pull request or question are welcomed and would
be appreciate!

As our time is precious, it should never be wasted.

In order to not waste yours, and to keep you feeling motivated by contributing,
please apply the following guidelines.

A request not well formulated would be rejected.  
But a reject does not
automatically mean the
end of the proposal.   
It may also be the beginnig of a new way to take.

However, every contributing will be processed and answered.

#### Discussion

<details><summary><b>Guidelines</b></summary>

Do not be afraid to start a new [discussion](https://github.com/AudeizReading/virtual-campus-42nice/discussions), if you have any questions. This section is made for this. There is no silly question.

Also, if you need the installation of a precise tool, the improvment of a
feature, whatever, the location is entirely
dedicated for this purpose.

Feel free to interact. Just be kind and polite to each others. Be patient, if
answers are not coming quickly.

Do not hesitate to transmit proposal and solutions to an already opened
discussion. Feel free to answer to each others. More fools, more fun.

I would take the liberty of muting/banishing anyone who will not be respectful to his neighbor.

We may not be
agree with everybody, but at least we can respect each others. Do not forget that
there is a human behind the screen. Sometimes, it is just a matter of misunderstanding.

</details>

#### Issues

<details><summary><b>Guidelines</b></summary>

If you find a security vulnerability, do NOT open an issue. Email
[alellouc@student.42nice.fr](mailto://alellouc@student.42nice.fr) instead.

If you noticed any bug, unexpected behaviour, please open an issue.

I will do my best for repairing what has failed. Please provide the following
context, for a better understanding of your troubles:

- Your host OS;
- The feature(s) from which you have encountered failure;
- A description on how it happens, screenshots are welcomed, code snippets also,
  what did you do, what did you expect to see and what did you see instead.
- Eventually, the resources that has helped you understand what has happened

Do not hesitate to use the comments section into the issue thread. Even the issue is
closed, a comment explaining why this should not be closed may change the
future of this closed one. Sometimes, it is just a matter of misunderstanding.

Every submitting would be studied and answered even if not accepted.

</details>

#### Pull Requests

<details><summary><b>Guidelines</b></summary>

- Fork the repository on your own account (the procedure is easily foundable).
- Be sure to have the latest version of the `main` branch.
- Create your own branch from the `main` branch.
- Work on your own on the feature you would to see improved.
    - **Makefile**
        - The **Makefile**'s rules have to be on a same subshell, on the same context line, if you prefer:  
            **Don't**:  
            ```Makefile
            target: prerequisites
                @instruction1
                @instruction2
            ```
            **Do**:  
            ```Makefile
            target: prerequisites
                @(instruction1 || true) \
                    && instruction2; \
                    instructions3 \
                    || instructions4
            ```
        - The commands have to be silented.  
            **Don't**:  
            ```Makefile
            target: prerequisites
                instruction1
            ```
            **Do**:  
            ```Makefile
            target: prerequisites
                @instruction1
            ```
        - If one rule executes a bash script, run it with the absolute path of
          the bash executable in interactive mode:  
            **Don't**:  
            ```Makefile
            target: prerequisites
                ./script-bash-that-install-features with parameters
            ```
            **Do**:  
            ```Makefile
            target: prerequisites
                /bin/bash -c "./script-bash-that-install-features with parameters"
            ```
        - Let the rule be `.PHONY`, if the target is not a filename.
    - **Dockerfile**
        - You should never submit a Dockerfile. It would instantly be rejected.  
        Instead, submit your need or idea on the issue page or discussion [OPEN AN ISSUE](https://github.com/AudeizReading/virtual-campus-42nice/issues) or [START A DISCUSSION](https://github.com/AudeizReading/virtual-campus-42nice/discussions).
    - **Script Syntax**
        - If you feel confident for integrating features into the main script,
          or wrting a scripting that be included in the main script, the shell syntax to be used is the `bash` syntax. Albeit, it is not portable, it offers broader options to manipulate string datas more easily.  
          Do only if you know what you are doing or be prepared to be rejected.
          It is rather to submit any idea or need to the dedicated pages: [OPEN AN ISSUE](https://github.com/AudeizReading/virtual-campus-42nice/issues) or [START A DISCUSSION](https://github.com/AudeizReading/virtual-campus-42nice/discussions).
    - **README**  
        The syntax used for README is markdown for GitHub (you can mix some HTML
        tags within). Try to follow the accessibility guidelines as much as possible:
        [Microsoft accessibility guidelines](https://learn.microsoft.com/fr-fr/style-guide/accessibility/accessibility-guidelines-requirements).
- Commit your enhancements on your new branch with the more explicit and
  detailed commit message.
- Push on your remote origin, then push on the upstram remote (here) on the same
  branch that you have just created. Every push on the inappropriate branch
  would be rejected. No work on the `main` branch are allowed.
- Go on the GitHub repository's pull request page, create a new pull request
  from your remote branch, to your upstream new name branch. A Pull Request made
  on the inappropriate branch would be closed and rejected.
- As I am the only one to review PR for the moment, I will process it as soon as
  possible, the most quickly possible, as it may be your work tool.

Do not hesitate to use the comments section into the PR thread. Even the PR is
closed, a comment explaining why the PR should not be closed may change the
future of this closed one. Sometimes, it is just a matter of misunderstanding.

Every submitting would be studied and answered even if not accepted.

Be assured that your request will not remain in vain.

This guide is subject to change on a regular basis.

</details>

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://makeapullrequest.com)

[CONTRIBUTING](.github/CONTRIBUTING.md)

### License

The project is under GNU GPLv3 license. You will find it here:
[LICENSE](.github/LICENSE.md)

### Authors

[AudeizReading](https://github.com/AudeizReading): You can contact me at [alellouc@student.42nice.fr](mailto://alellouc@student.42nice.fr), or via our regular private 42 communication tools.

<sub>This project is subject to change on a regular basis.</sub>
