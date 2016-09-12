# multiple_md5_collisions
Script could be used to generate multiple colliding binary blobs and then generate exploit: e.g. automatically add if else statements and different payloads for all each colliding blob.
## What is going on?
The md5 hashing algorithm has been broken since 2004. Today, anyone
can generate md5 collisions in a matter of seconds using the
[hashclash](https://www.win.tue.nl/hashclash/) tool written by Marc
Stevens.  Note, however, that this tool will not let you generate any
reasonable text and only generates a pair. But what if you want 5
colliding texts? Or N? And how to use collisions?
## What exactly this script does?
1) Automates creation of 2^N colliding blobs.  
2) Automates creation of meaningful exploits using these colliding texts.
## How does such an exploit usually look?
The script generates 2^N files, all of which have different behaviour, but have the same md5sum.  
The general structure of every file is as follows:
Let's consider a meaningful exploit to be any set of multiple files
with same md5 hash, but different behavior. The easiest way to create
such an exploit would be to generate the file with following
structure:

**colliding_file_$i**
```python
blob = 'binary blob $i'
if blob == blob1:
	behavior1()
elif blob == blob2:
	behavior2()
...
elif blob == blob$i:
	behavior$i()
...
else:
	some_other_behavior()
```

This repo has an example for python. See more info and how to configure it for postscript [in my blog](https://sergeyfrolov.github.io/2016/09/multiple-md5-collisions).
## Wait, you can totally make the exploit shorter/more elegant by~
Yep, I know. But this approach is general and would work for python and something like postscript(and almost anything).
