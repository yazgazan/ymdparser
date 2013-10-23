
YMDParser = require "./lib/index"

parser = new YMDParser

parser.loadFile "test.md", ->

  ret = @parseMarkdown (success) ->
    if not success
      throw Error "error parsing markdown"
    # console.log JSON.stringify md, null, 2
    console.log @toHtml()

