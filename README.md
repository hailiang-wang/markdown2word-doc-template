# markdown2word-doc-template

## Sample and Template of Markup Markdown

Preprocessor for Markdown files to generate a table of contents and other documentation needs.

[markup-markdown](https://github.com/hailiang-wang/markup-markdown)

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
dos2unix scripts/fix_dos2unix.sh
scripts/fix_dos2unix.sh
```
