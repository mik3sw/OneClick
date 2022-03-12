# OneClick

<div align="center">
  <img src="128x128logo.png">
  </div>
<br><br>

![](imgs/im1.png)

![](https://forthebadge.com/images/badges/made-with-swift.svg)
![](https://forthebadge.com/images/badges/open-source.svg)

OneClick can give you quick access to some macOS functions from MenuBar!

* **macOS 12.x** (Monterey)
* **Intel app** (only 1.4 and before)
* **Apple Silicon app** (all versions)

## 💾 [Downloads](https://github.com/mik3sw/OneClick/releases) 
[![Github All Releases](https://img.shields.io/github/downloads/mik3sw/OneClick/total.svg?style=for-the-badge&logo=github&color=blueviolet)]() 


<details>
<summary>Show functions</summary>
<br>

### Hide/Show desktop
Commands:

* ```defaults write com.apple.finder CreateDesktop false ; killall Finder```
* ```defaults write com.apple.finder CreateDesktop true ; killall Finder```


### Hide/Show hidden files/folders
Commands:

* ```defaults write com.apple.finder AppleShowAllFiles -boolean true ; killall Finder```
* ```defaults write com.apple.finder AppleShowAllFiles -boolean false ; killall Finder```

### Hide/Show dock
Commands:

* ```osascript -e 'tell application \"System Events\" to set the autohide of the dock preferences to true'```
* ```osascript -e 'tell application \"System Events\" to set the autohide of the dock preferences to false'```

### Enable/disable power saving
Commands:

* ```osascript -e 'do shell script \"pmset -a lowpowermode 1\" with administrator privileges'```
* ```osascript -e 'do shell script \"pmset -a lowpowermode 0\" with administrator privileges'```
* these commands need root access (the app will ask for administrator password or touchID)

### Enable/disable dark mode
Commands:

* ```osascript -e 'tell application \"System Events\" to tell appearance preferences to set dark mode to true'```
* ```osascript -e 'tell application \"System Events\" to tell appearance preferences to set dark mode to false'```


### Caffeinate
Commands:

* ```caffeinate```
* ```killall caffeinate```


### Empty trash
Command:

* ```osascript -e 'tell application \"Finder\" to empty trash'```

### Clear memory
Command:

* ```osascript -e 'do shell script \"purge\" with administrator privileges'```

### Take screenshot
Command:

* ```screencapture -T 3 -t png -P Desktop/screenshot.png```

</details>



## ⚙️ Settings

From settings you can select Themes (dark and light), "launch at login" function and edit the main view elements.

| General  |  Edit  |
|---|---|
|  ![](imgs/General.png) | ![](imgs/Edit.png)  |





## 🎨 Themes

ToDo: 
* Select image from storage


|   |   |   |   |   |   |
|---|---|---|---|---|---|
| ![](imgs/lightThemes/1.png)  |  ![](imgs/lightThemes/2.png) |  ![](imgs/lightThemes/3.png) | ![](imgs/lightThemes/4.png)  | ![](imgs/lightThemes/5.png)  | ![](imgs/lightThemes/6.png) |
| ![](imgs/darkThemes/1.png)  | ![](imgs/darkThemes/2.png)  |  ![](imgs/darkThemes/3.png) | ![](imgs/darkThemes/4.png)  | ![](imgs/darkThemes/5.png)  |  ![](imgs/darkThemes/6.png) |


## Credits

* [Launch at login](https://github.com/sindresorhus/LaunchAtLogin)
