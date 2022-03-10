# CafeHub
iOS app for finding places in Vienna powered by Goodnight.at Lokalführer database.

App is not finished and some bugs could persist, for example: geocodeAddressString from human readable address to CLLocation with the help of MapKit has it's
limits to the API and could not sometimes get timedout; Firebase free quota is only 50k reads per day

# What was used

* **Firebase**: storing data about each place in the cloud with the help of Firestore
* **SDWebImage**: Showing and downloading images with URL
* **TagListView**: Appearences of types/tags of each place throughout
* **CoreData**: persistance storage of the saved places
* **MapKit**: showing each place and short info about it on the Map Controller under Tab Bar. 
    Additionally for getting CLLocation out of the place address and calculating distance to the user location

# Functionality

Onboarding screens are present to help user save places and choose types of those places to calculate simple "match" throughout the app

Whole functionality of the app could be accessed with 4 tabs:
* Home Screen: has 3 main sections
  * "New/Trending places": separate collection with IDs on Firestore, could be updated in the cloud
  * "You may like": sorted by "match"
  * "Near me": sorted by location distance to user
  * additional section "Want to go": only present when user has saved one or more places to corresponding list
* Search Screen: all of the places are shown and could be searched through
* Saved Places Screen: places when saved appear on the main table view, additionaly they could be deleted 
with the left swipe and added to another list "Want to go" with the right swipe. Same process goes for "Want to go" list
* Map Screen: places appear on map as annotations and a an additional button to switch between all of the places and only saved ones
