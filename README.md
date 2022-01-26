My Unix (Linux + Mac) configuration and tools. It only uses git, no dotfile
manager or links.

The main idea is that you ignore all files in your $HOME directory except for
those listed in `.gitignore`. It's based on
https://gist.github.com/lonetwin/9636897.

## Adding new file

```
cd
echo '!.bashrc' >> .gitignore
git add .bashrc
```

## Setting up on a new machine

Add the machine's ssh key (`~/.ssh/id_rsa.pub`) to GitHub and then:

```
cd
git init
git remote add origin git@github.com:jreisinger/HOME.git
git fetch
git reset origin/main
git checkout --track origin/main
git checkout .
```
