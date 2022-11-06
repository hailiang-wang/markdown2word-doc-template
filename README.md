# markdown2word-doc-template

## Create new project

```bash
mkdir PROJECT_NAME && cd "$_"
curl -L https://github.com/hailiang-wang/markdown2word-doc-template/tarball/master | tar xz --strip-components=1
```

## Build

[Docs](./BUILD.md)

## Trouble Shooting

### Script Error bad interpreter

`/bin/bash^M: bad interpreter: No such file or directory`


Solution - 

```
cd PROJECT_DIR
dos2unix scripts/*.sh
dos2unix scripts/formatters/*.py
```
