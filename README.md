What is it?
===========

A simple way to get a dynamic tree view in your Ember.js apps without losing too much control
when the procedural API of jsTree is translated into the more declarative style of Ember
properties.

Usage
-----

Check tests/index.html for usage. The basic idea is that the js-tree component has a list
of roots which you can manipulate. It's important to use Ember.Array's array operations,
for example ```objectAt``` and ```pushObject```. Each item in the roots should be
EmberJsTree.Node objects.