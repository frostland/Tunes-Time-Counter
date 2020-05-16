# Tunes Time Counter

## TODO
Nothing! 😊

## To Generate `iTunes.h` and `Music.h`
```bash
# On a computer with iTunes installed (before Catalina)
sdef /Applications/iTunes.app | sdp -fh --basename "iTunes"
# On a computer with Music installed (Catalina and later)
sdef /System/Applications/Music.app | sdp -fh --basename "Music"
```

## To Generate the Help Index
```bash
hiutil -C -a -g -s en -l en -vv -f Tunes\ Time\ Counter/Tunes\ Time\ Counter.help/Contents/Resources/en.lproj/TunesTimeCounter.helpindex Tunes\ Time\ Counter/Tunes\ Time\ Counter.help/Contents/Resources/en.lproj
```
(Once for each language in the help folder.)
