[![Gem Version](https://badge.fury.io/rb/synx.svg)](http://badge.fury.io/rb/synx)
 [![Build Status](https://travis-ci.org/venmo/synx.svg?branch=master)](https://travis-ci.org/venmo/synx)

![synx logo](https://raw.githubusercontent.com/venmo/synx/marklarr/dev/docs/images/synx-logo.png?token=760261__eyJzY29wZSI6IlJhd0Jsb2I6dmVubW8vc3lueC9tYXJrbGFyci9kZXYvZG9jcy9pbWFnZXMvc3lueC1sb2dvLnBuZyIsImV4cGlyZXMiOjE0MDE5MzExNDF9--6c8a22318eaafed2185cb16d39189dcadb75c742)

A command-line tool that reorganizes your Xcode project folder to match your Xcode groups.

![synx gif](https://raw.githubusercontent.com/venmo/synx/marklarr/dev/docs/images/synx.gif?token=760261__eyJzY29wZSI6IlJhd0Jsb2I6dmVubW8vc3lueC9tYXJrbGFyci9kZXYvZG9jcy9pbWFnZXMvc3lueC5naWYiLCJleHBpcmVzIjoxNDAxODU2NzAyfQ%3D%3D--fc7d8546f3d4860df9024b1ee82ea13b86a2da88)

##### Xcode

![synx Xcode](https://raw.githubusercontent.com/venmo/synx/marklarr/dev/docs/images/synx-Xcode.jpg?token=760261__eyJzY29wZSI6IlJhd0Jsb2I6dmVubW8vc3lueC9tYXJrbGFyci9kZXYvZG9jcy9pbWFnZXMvc3lueC1YY29kZS5qcGciLCJleHBpcmVzIjoxNDAxOTMxMDY5fQ%3D%3D--969e312f6ee33430855c495f25d9f5ff78fa9e96)

##### Finder

![synx finder before/after](https://raw.githubusercontent.com/venmo/synx/marklarr/dev/docs/images/synx-finder-before-after.png?token=760261__eyJzY29wZSI6IlJhd0Jsb2I6dmVubW8vc3lueC9tYXJrbGFyci9kZXYvZG9jcy9pbWFnZXMvc3lueC1maW5kZXItYmVmb3JlLWFmdGVyLnBuZyIsImV4cGlyZXMiOjE0MDE5MzEwOTd9--8cff7616e4af2f6f2eed624623092745184c0235)

## Installation

    $ gem install synx

## Usage

### Basic

**WARNING: Make sure that your project is backed up through source control before doing anything**

Execute the command on your project to have it reorganize the files on the file system:

     $ synx path/to/my/project.xcodeproj
     
It may have confused cocoapods. Pod install, if you use them:

    $ pod install
    
You're good to go!

### Advanced

Synx supports the following options:

```
  --prune, -p                   remove source files and image resources that are not referenced by the the xcode project
  --no-default-exclusions       doesn't use the default exclusions of /Libraries, /Frameworks, and /Products
  --exclusion, -e EXCLUSION     ignore an Xcode group while syncing
```

OCMock, for example, could have done:

    $ synx -p -e=/OCMock/Core -e=/OCKMockTests Source/OCMock.xcodeproj

if they wanted to not sync the `OCMock/Core` and `OCMockTests` groups, and also remove (`-p`) any image/source files found by synx that weren't ever referenced by any groups in Xcode.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

* [@vrjbndr](https://github.com/vrjbndr), awesome logo!
* [@ayanonagon](https://github.com/ayanonagon) and [@benzguo](https://github.com/benzguo), feedback.
