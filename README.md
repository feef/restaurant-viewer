# restaurant-viewer
A simple application for displaying restaurants and their details

*Task*

- show restaurants around you
  - map panning
- restaurant detail page

*General*

- don't over-engineer it
- UI is simple, go for code-only for performance

*API endpoints*

- https://developer.foursquare.com/docs/api-reference/venues/search/
  - specify "ll", "categoryId" (4d4b7105d754a06374d81259), "radius" (based on zoom level)
- https://developer.foursquare.com/docs/api-reference/venues/details
  - specify venue ID

*Models*

- VenueLocation
  - lat, lon, ID, name
- VenueDetails
  - ID, name, bestPhoto, rating, location.address (optional), lat, lon, description, url, hours, menu.mobileUrl

*Screens / functionality*

- Map
  - home screen
  - full screen map
  - overlay view for showing error / loading state
  - pins representing individual restaurants loaded from API
  - tap pin details to see full restaurant details
- RestaurantDetail
  - presented modally
  - cells with VenueDetails contents
  - basic loading / error states

*nice to haves - won't include*

- Localization
- Map
  - show restaurant name on annotation tap, details on accessory tap from overlay
- RestaurantDetail
  - open webpages from tap of URL cells
  - show venue "bestPhoto" in header

*exposed APIs worth mentioning*

- APIManager
  - return VenueLocation objects given center, radius
  - return VenueDetails objects given ID
- MapViewModel
  - relays for annotations, loading state
  - methods for handling map region change, view loading, retrying last request for VenueLocation objects
- RestaurantDetailsViewModel
  - relays for loading state, ViewModel

*plan*

- models, Protocol for APIManager, TestingAPIManager, tests around model parsing
- map showing nearby locations (returned by TestingAPIManager), test around view did load handling
- map interaction handling (loading new locations, starting RestaurantDetail coordinator), tests around new region handling + starting RestaurantDetail coordinator
- map loading state display + retry handling, tests around state relay + retry handling
- restaurantDetail close handling and display (with testing data) from map pin tap
- integration of actual API manager and requests
