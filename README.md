# Publish with relations

Publish with relations builds on Tom's [gist](https://gist.github.com/tmeasday/4042603) 
to provide a convenient way to publish associated records.

## Installation

Publish with relations can be installed with [Meteorite](https://github.com/oortcloud/meteorite/).
From inside a Meteorite-managed app:

``` sh
$ mrt add publish-with-relations
```

## API

### Basics

```javascript
  Meteor.publish('post', function(id) {
    Meteor.publishWithRelations({
      handle: this,
      collection: Posts,
      filter: id,
      mappings: [{
        key: 'authorId',
        collection: Meteor.users
      }, {
        reverse: true,
        key: 'postId',
        collection: Comments,
        filter: { approved: true },
        options: {
          limit: 10,
          sort: { createdAt: -1 }
        },
        mappings: [{
          key: 'userId',
          collection: Meteor.users
        }]
      }]
    });
  });
```

This will publish the post specified by id parameter together
with user profile of its author and a list of ten approved comments
with their author profiles as well.

With one call we publish a post to the ```Posts``` collection, post
comments to the ```Comments``` collection and corresponding authors to
the ```Meteor.users``` collection so we have all the data we need to
display a post.

You can check another (more complex) example at this [gist](https://gist.github.com/erundook/5012259).

### Changelog
#### v0.1.4
- Foreign key can be an array now. Thanks [Tom](http://github.com/tmeasday)!

### Compatibility notes
Use <= v0.1.1 for meteor version < 0.5.7

