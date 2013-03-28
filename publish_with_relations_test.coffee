# a 'publication' that just records stuff
class PubMock
  constructor: () ->
    @activities = []
  
  added: (name, id) ->
    @activities.push {type: 'added', collection: name, id: id}
  
  changed: (name, id) ->
    @activities.push {type: 'changed', collection: name, id: id}
  
  removed: (name, id) ->
    @activities.push {type: 'removed', collection: name, id: id}
  
  ready: ->
    @activities.push {type: 'ready'}
  
  onStop: (cb) ->
    @_onStop = cb
  
  stop: () ->
    @_onStop() if @_onStop

# will be overwritten
Boards = Lists = Tasks = null
settings = null

prepare = (test) ->
  run = test.runId()
  Boards = new Meteor.Collection "boards_#{run}"
  Lists = new Meteor.Collection "lists_#{run}"
  Tasks = new Meteor.Collection "tasks_#{run}"
  
  # insert some data
  boardId = Boards.insert name: 'board'
  listId = Lists.insert name: 'list', boardId: boardId
  taskId = Tasks.insert name: 'task', listId: listId
  
  settings = 
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

  

Tinytest.add "Publish with Relations: ready is only called once", (test) ->
  prepare(test)
  
  pub = new PubMock
  Meteor.publishWithRelations _.extend(settings, {handle: pub})
  
  readys = (activity for activity in pub.activities when activity.type == 'ready')
  test.equal readys.length, 1

Tinytest.add "Publish with Relations: Nested subscriptions stop", (test) ->
  prepare(test)
  
  pub = new PubMock
  Meteor.publishWithRelations _.extend(settings, {handle: pub})
  
  count = pub.activities.length
  
  # stop the sub, but then insert some more stuff
  pub.stop()
  boardId = Boards.insert name: 'new board'
  listId = Lists.insert name: 'new list', boardId: boardId
  taskId = Tasks.insert name: 'new task', listId: listId
  
  # nothing new has happened
  test.equal pub.activities.length, count
  
  
  
  