
MDParser = require "mdparser"

bnf = require './bnf'
grammar = require './grammar'

class YMDParser extends MDParser
  constructor: ->
    super()
    @initHtmlBindings()
    @grammars = grammar
    # console.log JSON.stringify @grammars, null, 2

  generateGrammar: ->
    super()
    @extendGrammar bnf

  initHtmlBindings: ->
    @cmds = {}
    @html =
      rule: ['<hr/>','']
      section: @html_section
      list: @html_list
      item: ['<li>', '</li>']
      code: ['<pre><p>', '</p></pre>']
      quote: ['<blockquote>', '</blockquote>']
      link_ref: @html_link_ref
      paragraph: ['<p>', '</p>']
      bold_and_underlined: ['<strong><em>', '</em></strong>']
      bold: ['<strong>', '</strong>']
      underlined: ['<em>', '</em>']
      link: @html_link
      image: @html_image
      title: ['<h1>', '</h1>']
      line: ['', "\n"]
      raw: ['', '']
      format_error: ['<strong><u>', '</u></strong>']
      escaped: @html_escape
      inline_code: ['<code>', '</code>']
      meta: @html_meta
      toc: @html_toc
      include: @html_include
      breakpage: ['', '']
      align: ['', '']
      reset: ['', '']
      font_size: ['', '']
      font_color: ['', '']
      bg_color: ['', '']
      line_spacing: ['', '']
      exponent: @html_exp
      format_cmd: @html_format_cmd
      cmd_error: ['<strong><u>', '</u></strong>']
      arg: @html_cmd_arg

  toHtml: (ast = @ast) ->
    if ast.type? and not @html[ast.type]?
      throw Error "Can't find '#{ast.type}'"
    if (typeof ast) is 'string'
      return ast
    ret = ''
    for node in ast.nodes
      ret += @toHtml node
    if not @html[ast.type]?
      return ret
    if (typeof @html[ast.type]) is 'object'
      return "#{@html[ast.type][0]}#{ret}#{@html[ast.type][1]}\n"
    return @html[ast.type].call this, ast, ret

  toRaw: (ast = @ast) ->
    ret = ''
    for node in ast.nodes
      if (typeof node) is 'string'
        ret += node
      else
        ret += @toRaw node
    return ret

  html_meta: (ast, ret) -> ''

  html_section: (ast, ret) ->
    tag = "h#{ast.level.length}"
    return "<#{tag}>#{ret}</#{tag}>\n"

  html_list: (ast, ret) ->
    if ast.nodes.length is 0
      return '<ul></ul>\n'
    if ast.nodes[0].ordered?
      return "<ol>\n#{ret}\n</ol>\n"
    return "<ul>\n#{ret}\n</ul>\n"

  html_link: (ast, ret) ->
    name = ast.name
    url = ast.url
    ref = ast.ref
    if (not url) and (not ref)
      throw Error "invalid link"
    if (not url) and (not name)
      name = ref
    if (not url)
      url = "##{ref}"
    if not name
      name = url
    return "<a href=\"#{url}\">#{name}</a>"

  html_link_ref: (ast, ret) ->
    return "<p id=\"#{ast.name}\">#{ast.name} : <a href=\"#{ast.url}\">#{ast.url}</a></p>\n"

  html_image: (ast, ret) ->
    name = ast.name
    url = ast.url
    if (not url)
      throw Error "invalid image"
    if not name
      name = url
    return "<img src=\"#{url}\" alt=\"#{name}\" title=\"#{name}\"/>\n"

  html_include: (ast, ret) ->
    fs = require 'fs'
    parser = new YMDParser
    file = fs.readFileSync ast.file, 'ascii'
    parser.loadString file
    return (parser.parseMarkdown -> @toHtml())

  html_toc: (ast, ret, tohtml = true) ->
    toc = ""
    for node in @ast.nodes
      if node.type is 'include'
        fs = require 'fs'
        parser = new YMDParser
        file = fs.readFileSync node.file, 'ascii'
        parser.loadString file
        parser.parseMarkdown -> null
        toc += parser.html_toc parser.ast, '', false
      continue if node.type isnt 'section'
      toc += (' ' for i in [0...((node.level.length - 1) * 2)]).join('')
      toc += '- '
      toc += @toRaw node
      toc += "\n"
    if tohtml is false
      return toc
    toc += "\n"
    parser = new YMDParser
    parser.loadString toc
    parser.parseMarkdown -> null
    return parser.toHtml()

  html_exp: (ast, ret) -> "<sup>#{ret}</sup>"

  html_format_cmd: (ast, ret) ->
    if not @cmds[ast.cmd]?
      return "<#{ast.cmd}>#{ret}</#{ast.cmd}>"
    return @cmds[ast.cmd].call this, ast, ret

  html_escape: (ast, ret) ->
    if ret is "\n"
      return "<br/>"
    return ret

YMDParser.MDParser = MDParser
module.exports = YMDParser

