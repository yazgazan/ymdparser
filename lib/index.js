// Generated by CoffeeScript 1.6.3
(function() {
  var MDParser, YMDParser, bnf, grammar,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  MDParser = require("mdparser");

  bnf = require('./bnf');

  grammar = require('./grammar');

  YMDParser = (function(_super) {
    __extends(YMDParser, _super);

    function YMDParser() {
      YMDParser.__super__.constructor.call(this);
      this.initHtmlBindings();
      this.grammars = grammar;
    }

    YMDParser.prototype.generateGrammar = function() {
      YMDParser.__super__.generateGrammar.call(this);
      return this.extendGrammar(bnf);
    };

    YMDParser.prototype.initHtmlBindings = function() {
      this.cmds = {};
      return this.html = {
        rule: ['<hr/>', ''],
        section: this.html_section,
        list: this.html_list,
        item: ['<li>', '</li>'],
        code: ['<pre><p>', '</p></pre>'],
        quote: ['<blockquote>', '</blockquote>'],
        link_ref: this.html_link_ref,
        paragraph: ['<p>', '</p>'],
        bold_and_underlined: ['<strong><em>', '</em></strong>'],
        bold: ['<strong>', '</strong>'],
        underlined: ['<em>', '</em>'],
        link: this.html_link,
        image: this.html_image,
        title: ['<h1>', '</h1>'],
        line: ['', "\n"],
        raw: ['', ''],
        format_error: ['<strong><u>', '</u></strong>'],
        escaped: this.html_escape,
        inline_code: ['<code>', '</code>'],
        meta: this.html_meta,
        toc: this.html_toc,
        include: this.html_include,
        breakpage: ['', ''],
        align: ['', ''],
        reset: ['', ''],
        font_size: ['', ''],
        font_color: ['', ''],
        bg_color: ['', ''],
        line_spacing: ['', ''],
        exponent: this.html_exp,
        format_cmd: this.html_format_cmd,
        cmd_error: ['<strong><u>', '</u></strong>'],
        arg: this.html_cmd_arg
      };
    };

    YMDParser.prototype.toHtml = function(ast) {
      var node, ret, _i, _len, _ref;
      if (ast == null) {
        ast = this.ast;
      }
      if ((ast.type != null) && (this.html[ast.type] == null)) {
        throw Error("Can't find '" + ast.type + "'");
      }
      if ((typeof ast) === 'string') {
        return ast;
      }
      ret = '';
      _ref = ast.nodes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        ret += this.toHtml(node);
      }
      if (this.html[ast.type] == null) {
        return ret;
      }
      if ((typeof this.html[ast.type]) === 'object') {
        return "" + this.html[ast.type][0] + ret + this.html[ast.type][1] + "\n";
      }
      return this.html[ast.type].call(this, ast, ret);
    };

    YMDParser.prototype.toRaw = function(ast) {
      var node, ret, _i, _len, _ref;
      if (ast == null) {
        ast = this.ast;
      }
      ret = '';
      _ref = ast.nodes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        if ((typeof node) === 'string') {
          ret += node;
        } else {
          ret += this.toRaw(node);
        }
      }
      return ret;
    };

    YMDParser.prototype.html_meta = function(ast, ret) {
      return '';
    };

    YMDParser.prototype.html_section = function(ast, ret) {
      var tag;
      tag = "h" + ast.level.length;
      return "<" + tag + ">" + ret + "</" + tag + ">\n";
    };

    YMDParser.prototype.html_list = function(ast, ret) {
      if (ast.nodes.length === 0) {
        return '<ul></ul>\n';
      }
      if (ast.nodes[0].ordered != null) {
        return "<ol>\n" + ret + "\n</ol>\n";
      }
      return "<ul>\n" + ret + "\n</ul>\n";
    };

    YMDParser.prototype.html_link = function(ast, ret) {
      var name, ref, url;
      name = ast.name;
      url = ast.url;
      ref = ast.ref;
      if ((!url) && (!ref)) {
        throw Error("invalid link");
      }
      if ((!url) && (!name)) {
        name = ref;
      }
      if (!url) {
        url = "#" + ref;
      }
      if (!name) {
        name = url;
      }
      return "<a href=\"" + url + "\">" + name + "</a>";
    };

    YMDParser.prototype.html_link_ref = function(ast, ret) {
      return "<p id=\"" + ast.name + "\">" + ast.name + " : <a href=\"" + ast.url + "\">" + ast.url + "</a></p>\n";
    };

    YMDParser.prototype.html_image = function(ast, ret) {
      var name, url;
      name = ast.name;
      url = ast.url;
      if (!url) {
        throw Error("invalid image");
      }
      if (!name) {
        name = url;
      }
      return "<img src=\"" + url + "\" alt=\"" + name + "\" title=\"" + name + "\"/>\n";
    };

    YMDParser.prototype.html_include = function(ast, ret) {
      var file, fs, parser;
      fs = require('fs');
      parser = new YMDParser;
      file = fs.readFileSync(ast.file, 'ascii');
      parser.loadString(file);
      return parser.parseMarkdown(function() {
        return this.toHtml();
      });
    };

    YMDParser.prototype.html_toc = function(ast, ret, tohtml) {
      var file, fs, i, node, parser, toc, _i, _len, _ref;
      if (tohtml == null) {
        tohtml = true;
      }
      toc = "";
      _ref = this.ast.nodes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        if (node.type === 'include') {
          fs = require('fs');
          parser = new YMDParser;
          file = fs.readFileSync(node.file, 'ascii');
          parser.loadString(file);
          parser.parseMarkdown(function() {
            return null;
          });
          toc += parser.html_toc(parser.ast, '', false);
        }
        if (node.type !== 'section') {
          continue;
        }
        toc += ((function() {
          var _j, _ref1, _results;
          _results = [];
          for (i = _j = 0, _ref1 = (node.level.length - 1) * 2; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
            _results.push(' ');
          }
          return _results;
        })()).join('');
        toc += '- ';
        toc += this.toRaw(node);
        toc += "\n";
      }
      if (tohtml === false) {
        return toc;
      }
      toc += "\n";
      parser = new YMDParser;
      parser.loadString(toc);
      parser.parseMarkdown(function() {
        return null;
      });
      return parser.toHtml();
    };

    YMDParser.prototype.html_exp = function(ast, ret) {
      return "<sup>" + ret + "</sup>";
    };

    YMDParser.prototype.html_format_cmd = function(ast, ret) {
      if (this.cmds[ast.cmd] == null) {
        return "<" + ast.cmd + ">" + ret + "</" + ast.cmd + ">";
      }
      return this.cmds[ast.cmd].call(this, ast, ret);
    };

    YMDParser.prototype.html_escape = function(ast, ret) {
      if (ret === "\n") {
        return "<br/>";
      }
      return ret;
    };

    return YMDParser;

  })(MDParser);

  YMDParser.MDParser = MDParser;

  module.exports = YMDParser;

}).call(this);