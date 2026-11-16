# Phase 0: The Blueprint
The app will get albums from the internet and show them in a list. I will store each album’s ID and title. The app will also track which album is selected and show a loading message while it gets the data.

# Phase 1: The List
I created an Album model and loaded the albums from the server. The app shows a loading indicator, the album list, or an error message. A list request returns many albums, so I convert each item into an Album.

# Phase 2: The Detail
I added a selectedAlbum variable. When I tap an album, the app shows its ID and title above the list. This changes what is shown on the page without opening a new page.

# Phase 3: The Delete
I added a Delete Album button. The app sends a delete request using the selected album’s ID and checks for a successful response before clearing the selection. JSONPlaceholder is a test service, so the album may still appear in the list.

# Phase 4: Validation and Reflection
I will test loading the list, selecting an album, deleting it, and using the app without an internet connection. The app should show an error message if it cannot load the albums.
