### Purpose
This demo project is meant to showcase my coding style. Project requirments can be found [here](https://github.com/Swiftly-Systems/code-exercise-ios).

### Instructions
To run the project, open in Xcode and select Product > Run (⌘R)


#### Developer's Notes
Some containers defined by the endPoint are too small to contain all visual elements of the discounted item. To handle this I used different CollectionViewCells within `main.storyboard`. I used the following priority:

- Image
- Price labels
- DisplayLabel

<img src="https://github.com/tathen/Swiftly_exercise/blob/main/Screenshot.png" width="400"/><img src="https://github.com/tathen/Swiftly_exercise/blob/main/Screenshot2.png" width="400"/>

To obtain server updates I implemented polling using Combine's `Timer` publisher
