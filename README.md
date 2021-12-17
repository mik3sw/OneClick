# OneClick

<div align="center">
  <img src="128x128logo.png">
  </div>
<br><br>

This simple menubar app can give you quick access to some macOS functions.
It only emulates terminal commands from a GUI

* macOS 12.x (Monterey)
* Intel app
* Apple Silicon app

## Functions

### Hide/Show desktop
Commands:

* ```defaults write com.apple.finder CreateDesktop false ; killall Finder```
* ```defaults write com.apple.finder CreateDesktop true ; killall Finder```


### Hide/Show hidden files/folders
Commands:

* ```defaults write com.apple.finder AppleShowAllFiles -boolean true ; killall Finder```
* ```defaults write com.apple.finder AppleShowAllFiles -boolean false ; killall Finder```

### Enable/disable power saving
Commands:

* ```osascript -e 'do shell script \"pmset -a lowpowermode 1\" with administrator privileges'```
* ```osascript -e 'do shell script \"pmset -a lowpowermode 0\" with administrator privileges'```
* these commands need root access (the app will ask for administrator password or touchID)

### Caffeinate
Commands:

* ```caffeinate```
* ```killall caffeinate```


<br><br>

<div align="center">
  <img src="screen.png">
</div>


