My Unix (Linux + Mac) configuration and tools. It only uses git, no dotfile
manager or links. The main idea is that you ignore all files in your $HOME
directory (see `.gitignore`). Then you manually add just those you want to track
and share. It's based on [this gist](https://gist.github.com/lonetwin/9636897).

List files currently being tracked under main branch

```
git ls-tree -r main --name-only
```

List ever tracked files

```
git log --pretty=format: --name-only --diff-filter=A | sort - | sed '/^$/d'
```

Add a new file

```
git add -f <file>
```

Set up on a new machine

```
# Add the machine's public ssh key (~/.ssh/id_rsa.pub) 
# to GitHub, to this project or globally, and then:
cd
git init
git remote add origin git@github.com:jreisinger/HOME.git
git fetch
git reset origin/main
git checkout --track origin/main
git checkout .
```
