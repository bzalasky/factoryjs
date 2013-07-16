require ["BackboneFactory", "backbone"], (BackboneFactory, Backbone) ->
  describe "BackboneFactory", ->

    it "should be available", ->
      expect(BackboneFactory).toBeDefined()

    it "should return a default object when no valid definition is found", ->
      expect(BackboneFactory.get("Base")).toBeDefined()
      expect(BackboneFactory.get("Base").on).toBeDefined()

    it "should initialize objects that support that interface", ->
      TestObject = initialize: ->
        @tested = true

      BackboneFactory.extend "Base", "TestObject", TestObject
      expect(BackboneFactory.get("TestObject")).toBeInstanceOf BackboneFactory.definitions.Base.constructor

    it "should return a view as defined", ->
      view = BackboneFactory.get("View")
      expect(view).toBeInstanceOf(Backbone.View)

    describe "extend method", ->
      BackboneFactory.extend "View", "Test.View",
        el: "body"
        render: ->
          @$el.append "<div class=\"test-item item-" + @cid + "\">" + (new Date()).getTime() + "</div>"

        model: "Test.Model"
      ,
        singleton: true
        mixins: ["one.View", "two.View"]

      BackboneFactory.extend "Model", "Test.Model",
        defaults:
          hello: "world"

        test: ->
          true
      ,
        singleton: true

      BackboneFactory.defineMixin "one.View",
        mixinOptions:
          one: true

        mixinitialize: ->
          @one = ->
            @mixinOptions.one

      BackboneFactory.defineMixin "two.View",
        mixinOptions:
          two: true

        mixinitialize: ->
          @two = @mixinOptions.two

      it "should have extend method", ->
        expect(BackboneFactory).toProvideMethod "extend"


      it "should return any model extended from the base", ->
        model = BackboneFactory.get("Test.Model")
        expect(model.get("hello")).toEqual "world"

      it "should have methods defined on the implementation", ->
        model = BackboneFactory.get("Test.Model")
        expect(model.test()).toBe true


      it "should support extended views with features", ->
        master = BackboneFactory.get("Test.View")
        master.render()
        expect($(".test-item").length).toBe 1
        expect(master.$el.get(0)).toEqual $("body").get(0)

      it "should include functionality and properties added by mixins", ->
        master = BackboneFactory.get("Test.View")
        expect(master.one()).toBe true
        expect(master.two).toBe true


    describe "Collection Support", ->
      it "should support getting a standard collection", ->
        collection = BackboneFactory.get("Collection", [1, 2, 3])
        expect(collection).toBeDefined()
        expect(collection).toBeInstanceOf(Backbone.Collection)

      it "should support getting a collection referring to a factory model", ->
        BackboneFactory.extend "Model", "FactoryModel",
          test: ->
            true
        BackboneFactory.extend "Collection", "FactoryCollection",
          model: "FactoryModel"

        collection = BackboneFactory.get("FactoryCollection", [{}, {}, {}]);
        expect(collection).toBeDefined()
        collection.each (model)->
          expect(model.test()).toBe true



