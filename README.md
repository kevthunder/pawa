# Pawa

PAWA : Porting Algorithms With Annotations. 

PAWA is meant to ease maintaining a library that must be written in two different languages. PAWA will transform files of language A with replace operations and line substitutions you put in your files in the form of comments. Then it will send them to your favorite diff viewer to compare with your existing files of language B. This is essentially telling you where you must make modifications in language B to port the modifications you did in language A.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pawa'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pawa

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/pawa/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
