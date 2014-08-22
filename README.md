What is it?
===========
A jstree wrapper for Ember.js.

Building
--------
Run ```grunt``` in root.

Usage
-----
Check tests/index.html for usage. The basic idea is that the js-tree component has a list
of roots which you can manipulate. It's important to use Ember.Array's array operations,
for example ```objectAt``` and ```pushObject```. Each root should be an EmberJsTree.Node object.