# Synx

A command-line tool that reorganizes your project files into folders that match Xcode's group structure.

#### OCMock, before Synx

![OCMock Before](https://raw.githubusercontent.com/venmo/synx/marklarr/dev/docs/images/OCMock-Xcode.jpg?token=760261__eyJzY29wZSI6IlJhd0Jsb2I6dmVubW8vc3lueC9tYXJrbGFyci9kZXYvZG9jcy9pbWFnZXMvT0NNb2NrLUZpbmRlci1CZWZvcmUuanBnIiwiZXhwaXJlcyI6MTQwMTg1NjM4NH0%3D--1a079341e97ab76fa31de3cc22391d4ecf39c719)

![OCMock Before](https://raw.githubusercontent.com/venmo/synx/marklarr/dev/docs/images/OCMock-Finder-Before.jpg?token=760261__eyJzY29wZSI6IlJhd0Jsb2I6dmVubW8vc3lueC9tYXJrbGFyci9kZXYvZG9jcy9pbWFnZXMvT0NNb2NrLUZpbmRlci1CZWZvcmUuanBnIiwiZXhwaXJlcyI6MTQwMTg1NjM4NH0%3D--1a079341e97ab76fa31de3cc22391d4ecf39c719)

#### OCMock, afer Synx

![OCMock After](https://raw.githubusercontent.com/venmo/synx/marklarr/dev/docs/images/OCMock-Finder-After.jpg?token=760261__eyJzY29wZSI6IlJhd0Jsb2I6dmVubW8vc3lueC9tYXJrbGFyci9kZXYvZG9jcy9pbWFnZXMvT0NNb2NrLUZpbmRlci1CZWZvcmUuanBnIiwiZXhwaXJlcyI6MTQwMTg1NjM4NH0%3D--1a079341e97ab76fa31de3cc22391d4ecf39c719)

## Installation

Add this line to your application's Gemfile:

    gem 'synx'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install synx

## Usage

Execute the command on yor project to have it reorganize the files on the file system:

     $ synx path/to/my/project.xcodeproj

Synx supports the following options:

```
--prune, -p                   remove source files and image resources that are not referenced by the the xcode project
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
