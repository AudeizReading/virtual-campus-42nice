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
