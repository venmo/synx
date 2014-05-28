[![Gem Version](https://badge.fury.io/rb/synx.svg)](http://badge.fury.io/rb/synx)

# Synx

![Synx Gif](https://raw.githubusercontent.com/venmo/synx/marklarr/dev/docs/images/synx.gif?token=760261__eyJzY29wZSI6IlJhd0Jsb2I6dmVubW8vc3lueC9tYXJrbGFyci9kZXYvZG9jcy9pbWFnZXMvc3lueC5naWYiLCJleHBpcmVzIjoxNDAxODU2NzAyfQ%3D%3D--fc7d8546f3d4860df9024b1ee82ea13b86a2da88)

A command-line tool that reorganizes your project files into folders that match Xcode's group structure.

#### OCMock, before Synx

##### Xcode

![OCMock Xcode](https://raw.githubusercontent.com/venmo/synx/marklarr/dev/docs/images/OCMock-Xcode.jpg?token=760261__eyJzY29wZSI6IlJhd0Jsb2I6dmVubW8vc3lueC9tYXJrbGFyci9kZXYvZG9jcy9pbWFnZXMvT0NNb2NrLVhjb2RlLmpwZyIsImV4cGlyZXMiOjE0MDE4NTY2ODN9--31a4b1efc4d430c586a51579a5056d5e98f1e411)

##### Finder
![OCMock Before](https://raw.githubusercontent.com/venmo/synx/marklarr/dev/docs/images/OCMock-Finder-Before.jpg?token=760261__eyJzY29wZSI6IlJhd0Jsb2I6dmVubW8vc3lueC9tYXJrbGFyci9kZXYvZG9jcy9pbWFnZXMvT0NNb2NrLUZpbmRlci1CZWZvcmUuanBnIiwiZXhwaXJlcyI6MTQwMTg1NjU4NX0%3D--b0be5c1d488759ed367510f825191837e35258e6)

#### OCMock, afer Synx

##### Finder

![OCMock After](https://raw.githubusercontent.com/venmo/synx/marklarr/dev/docs/images/OCMock-Finder-After.jpg?token=760261__eyJzY29wZSI6IlJhd0Jsb2I6dmVubW8vc3lueC9tYXJrbGFyci9kZXYvZG9jcy9pbWFnZXMvT0NNb2NrLUZpbmRlci1BZnRlci5qcGciLCJleHBpcmVzIjoxNDAxODU2NjU5fQ%3D%3D--1fe38806260fe0cb8ea47ec93b84c1c3482e3d18)

## Installation

Add this line to your application's Gemfile:

    gem 'synx'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install synx

## Usage

**WARNING: Make sure that your project is backed up through source control before doing anything**

Execute the command on your project to have it reorganize the files on the file system:

     $ synx path/to/my/project.xcodeproj

Synx supports the following options:

```
  --prune, -p                   remove source files and image resources that are not referenced by the the xcode project
  --no-default-exclusions       doesn't use the default exclusions of /Libraries, /Frameworks, and /Products
  --exclusion, -e EXCLUSION     ignore an Xcode group while syncing
```
     
It may have confused cocoapods. Pod install, if you use them:

    $ pod
    
You're good to go!


## Contributing

1. Fork it ( https://github.com/[my-github-username]/synx/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
