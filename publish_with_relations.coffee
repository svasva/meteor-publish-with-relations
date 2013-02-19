Meteor.publishWithRelations = (params) ->
  pub = params.handle
  collection = params.collection
  associations = {}
  publishAssoc = (collection, filter, options) ->
    collection.find(filter, options).observe
      added: (obj) =>
        pub.set(collection._name, obj._id, obj)
        pub.flush()
      changed: (obj) =>
        pub.set(collection._name, obj._id, obj)
        pub.flush()
      removed: (obj) =>
        pub.unset(collection._name, obj._id, _.keys(obj))
        pub.flush()
  doMapping = (obj, mappings) ->
    for mapping in params.mappings
      mapFilter = {}
      mapOptions = {}
      if mapping.reverse
        objKey = mapping.collection._name
        mapFilter[mapping.key] = obj._id
      else
        objKey = mapping.key
        mapFilter._id = obj[mapping.key]
      _.extend(mapFilter, mapping.filter)
      _.extend(mapOptions, mapping.options)
      if mapping.mappings
        Meteor.publishWithRelations
          handle: pub
          collection: mapping.collection
          filter: mapFilter
          options: mapOptions
          mappings: mapping.mappings
      else
        associations[obj._id][objKey]?.stop()
        associations[obj._id][objKey] =
          publishAssoc(mapping.collection, mapFilter, mapOptions)

  collectionHandle = collection.find(params.filter, params.options).observe
    added: (obj) ->
      pub.set(collection._name, obj._id, obj)
      pub.flush()
      associations[obj._id] ?= {}
      doMapping(obj, params.mappings)
    changed: (obj, idx, oldObj) ->
      changedKeys = {}
      _.each obj, (value, key) ->
        unless oldObj[key] is value
          changedKeys[key] = value
          changedMappings = _.where(params.mappings, {key: key, reverse: false})
          doMapping(obj, changedMappings)
      pub.set(collection._name, obj._id, changedKeys)
      pub.flush()
    removed: (obj) ->
      handle.stop() for handle in associations[obj._id]
      pub.unset(collection._name, obj._id, _.keys(obj))
      pub.flush()
  pub.complete()
  pub.flush()

  pub.onStop ->
    for association in associations
      handle.stop() for handle in association
    collectionHandle.stop()
