class StockTwitsMatcher
  constructor: () ->
    this.regexen = /(^|[\s\,\.\-\+\(\/\"\']\$?|^\$)(\$([a-z1-9]{1}[a-z]{1,3}_F|(?!\d+[bmkts]{1}?(il(lion)?|ln|m|n)?\b|[\d]+\b)(?!\d+usd)[a-z0-9]{1,9}(?:[-\.]{1}[a-z]{1,2})?(?:[-\.]{1}[a-z]{1,2})?))\b(?!\$)/ig

  extractCashtags: (text) ->
    matches = []
    text.replace this.regexen, (match, prefix, cashtag) ->
      matches.push cashtag.slice(1)
      return
    matches

  autoLinkCashtags: (text, options) ->
    if typeof options == 'function'
      return text.replace(this.regexen, (match, before, cashtag) ->
        before + options.call(this, cashtag.toUpperCase(), cashtag.toUpperCase().slice(1))
      )
    html = []
    opts = options or {}
    htmlAttributes = {}
    for k of options
      if k != 'urlClass' and k != 'urlTarget' and k != 'urlNofollow' and k != 'url'
        htmlAttributes[k] = options[k]
    classes = []
    if htmlAttributes['class']
      classes.push htmlAttributes['class']
    if opts.urlClass == undefined
      classes.push 'stwt-url cashtag'
    else if opts.urlClass
      classes.push opts.urlClass
    htmlAttributes['class'] = classes.join(' ')
    if opts.urlTarget
      htmlAttributes.target = opts.urlTarget
    if opts.urlNofollow
      htmlAttributes.rel = 'nofollow'
    opts.url = opts.url or 'http://stocktwits.com/symbol/%s'
    htmlAttributes.href = opts.url
    text.replace this.regexen, (match, before, cashtag) ->
      `var html`
      cashtag = cashtag.toUpperCase()
      html = ''
      v = undefined
      for k of htmlAttributes
        `k = k`
        if v = htmlAttributes[k]
          html += ' ' + k + '="' + v.replace('%s', cashtag.slice(1)) + '"'
      before + '<a' + html + '>' + cashtag + '</a>'
module.exports = StockTwitsMatcher
