# CafeHub
iOS app for finding places in Vienna powered by Goodnight.at Lokalführer database.

<p float="left">
    <img src="https://user-images.githubusercontent.com/78689724/158013474-e56fa1d3-bdb1-4a9c-adb4-971da2d1c925.png" width="200">
    <img src="https://user-images.githubusercontent.com/78689724/158013721-26d1bf44-8cd3-42c2-b6b9-0a51d86567b7.png" width="200">
    <img src="https://user-images.githubusercontent.com/78689724/158013478-86bd4bb7-75e6-4e69-84a2-06f8ad0f8673.png" width="200">
    <img src="https://user-images.githubusercontent.com/78689724/158013481-b46081c2-3584-4565-a489-2ba9e7ca4f45.png" width="200">
</p>

App is not finished and some bugs could persist, for example: geocodeAddressString from human readable address to CLLocation with the help of MapKit has it's
limits to the API and could not sometimes get timedout; Firebase free quota is only 50k reads per day

# What was used

* **Firebase**: storing data about each place in the cloud with the help of Firestore
* **SDWebImage**: Showing and downloading images with URL
* **TagListView**: Appearences of types/tags of each place throughout
* **CoreData**: persistance storage of the saved places
* **MapKit**: showing each place and short info about it on the Map Controller under Tab Bar. 
    Additionally for getting CLLocation out of the place address and calculating distance to the user location
* Additionally database of places was scrapped from goodnight.at with the help of Octoparse

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
