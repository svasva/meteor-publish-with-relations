# a 'publication' that just records stuff
class PubMock
  constructor: () ->
    @activity = []
  
  added: (name, id) ->
    console.log('added')
    @activity.push {type: 'added', collection: name, id: id}
  
  changed: (name, id) ->
    @activity.push {type: 'changed', collection: name, id: id}
  
  removed: (name, id) ->
    @activity.push {type: 'removed', collection: name, id: id}
  
  ready: ->
    @activity.push {type: 'ready'}
  
  onStop: (cb) ->
    @onStop = cb
  
  stop: () ->
    @onStop() if @onStop

Tinytest.add "Publish with Relations: Nested subscriptions stop", (test) ->
  Boards = new Meteor.Collection 'boards'
  Lists = new Meteor.Collection 'lists'
  Tasks = new Meteor.Collection 'tasks'
  
  # insert some data
  boardId = Boards.insert name: 'board'
  listId = Lists.insert name: 'list', boardId: boardId
  taskId = Tasks.insert name: 'task', listId: listId
  
  # now 'publish'
  pub = new PubMock
  Meteor.publishWithRelations
    handle: pub
    collection: Boards
    filter: {}
    
    mappings: [{
      collection: Lists
      key: 'boardId'
      reverse: true
      
      mappings: [{
        collection: Tasks
        key: 'listId'
        reverse: true
      }]
    }]
  
  # should have three added + a ready event
  test.equal pub.activity.length, 4