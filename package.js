Package.describe({
  summary: "Publish associated collections at once."
});

Package.on_use(function(api) {
  api.use('coffeescript', 'server');
  api.add_files('publish_with_relations.coffee', 'server');
});

Package.on_test(function(api) {
  api.use('publish-with-relations');
  
  api.add_files('publish_with_relations_test.coffee', 'server');
});