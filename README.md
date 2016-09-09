# multiple_md5_collisions
Script could be used to generate multiple colliding binary blobs and then generate exploit: e.g. automatically add if else statements and different payloads for all each colliding blob.
## What is going on?
md5 hashing algorithm has been broken since 2004. Today, even not-so-powerful laptop of mine can compute the pair of colliding hashes in about a second, using a [tool by written by Marc Stevens](https://www.win.tue.nl/hashclash/).  
However, this tool generates only a pair of colliding(e.g. having the same md5sum) texts. But what if you want 5? Or N? And what's the point of colliding texts, if you can't decide in advance what they would be?
## What exactly this script does?
1) Automates creation of 2^N colliding blobs.  
2) Automates creation of meaningful exploits using these colliding texts.
## How does such an exploit usually look?
The script generates 2^N files, all of which have different behaviour, but have the same md5sum.  
The general structure of every file is as follows:
```
prefix
binary_blob = (One of 2^N binary blobs, that are different, but have the same md5sum)
if binary_blob == blob1 {
  behaviour1
}elseif binary_blob == blob2 {
  behaviour2
}elseif binary_blob == blob3 {
...
else {
  behaviour2^N
}
suffix
```
This repo has an example for python
## Wait, you can totally make the exploit shorter/more elegant by~
Yep, I know. But this one is more general and would work for python and something like postscript.
