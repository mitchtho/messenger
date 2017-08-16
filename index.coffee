{assign} =
  Object

{relativeTime} =
  require 'human-date'

prevent = (event) ->
  event.preventDefault()

remove = (item, array) ->
  array.filter (value) ->
    value != item

faces = '
  01w.jpg	11m.jpg	21w.jpg	31m.jpg	41w.jpg
  02m.jpg	12m.jpg	22w.jpg	32m.jpg	42w.jpg
  03w.jpg	13m.jpg	23w.jpg	33w.jpg	43w.jpg
  04w.jpg	14m.jpg	24w.jpg	34m.jpg	44w.jpg
  05w.jpg	15w.jpg	25w.jpg	35w.jpg	45m.jpg
  06w.jpg	16w.jpg	26m.jpg	36m.jpg	46w.jpg
  07w.jpg	17w.jpg	27m.jpg	37w.jpg	47w.jpg
  08m.jpg	18w.jpg	28m.jpg	38w.jpg	48m.jpg
  09w.jpg	19m.jpg	29w.jpg	39w.jpg	49w.jpg
  10m.jpg	20w.jpg	30w.jpg	40w.jpg	50w.jpg
'.split /\s/

{name, lorem, date} =
  require 'faker'

random = (array) ->
  array[Math.floor(Math.random() * array.length)]

users =
  for value in [0..49]
    image = random faces
    id: value
    image: "faces/#{image}"
    name: name.findName()
    message: lorem.sentence()
    active: date.recent()
    messages:
      for value in [1..100]
        me: random [true, false]
        text: lorem.sentence()

window.onload = ->

  # css

  {createRenderer} = require 'fela'
  styles = createRenderer()
  style = styles.renderRule
  rule = (selector, object) ->
    styles.renderStatic object, selector

  rule '*',
    margin: 0
    padding: 0
    font: 'inherit'
    color: 'inherit'
    outline: 'none'
    border: 'none'
    textDecoration: 'none'

  rule 'html',
    fontFamily: 'Rubik'
    fontSize: '10px'

  rule 'body',
    fontSize: '1.5em'
    '-webkitFontSmoothing': 'antialiased'

  rule 'body, html',
    width: '100%'
    height: '100%'

  {render} = require 'fela-dom'
  render styles

  # html

  h = require 'inferno-hyperscript'
  dom = document.querySelector 'app'

  messenger = ({chats, maximized}) ->
    className = style ->
      opts =
        '@media (max-width: 700px)':
          '& sidebar':
            width: '100%'
          '& conversations':
            left: 0
      unless maximized
        opts['@media (min-width: 700px)'] =
          '& conversation':
            height: '50rem'
            width: '30rem'
          '& input':
            padding: '1.4em'
      opts
    h 'messenger', {className}, [
      h sidebar
      if chats.length
        h conversations, {chats}
    ]

  conversations = ({chats}) ->
    className = style ->
      position: 'fixed'
      display: 'flex'
      top: 0
      right: 0
      bottom: 0
      left: '30rem'
      background: 'white'
      boxShadow: '0 .7em 2em rgba(0,0,0,.1)'
      zIndex: 1
      '& conversation:first-child':
        margin: 0
    h 'conversations', {className}, [
      for chat in chats
        h conversation, chat
    ]

  conversation = (user) ->
    className = style ->
      display: 'block'
      width: '100%'
      height: '100%'
      position: 'relative'
      marginLeft: '1em'
      flex: '0 0 auto'
      alignSelf: 'flex-end'
      boxShadow: '0 .7em 2em rgba(0,0,0,.1)'
    h 'conversation', {className}, [
      h header, user
      h messages, user
      h form
    ]

  header = ({id, name, active}) ->
    {maximized} = getState()
    className = style ->
      position: 'absolute'
      display: 'flex'
      top: 0
      left: 0
      right: 0
      zIndex: 1
      height: '9rem'
      background: 'white'
      flexDirection: 'column'
      alignItems: 'center'
      justifyContent: 'center'
      boxShadow: '0 .7em 2em rgba(0,0,0,.1)'
    h 'header', {className}, [
      h header_name, name
      h header_active, {active}
      if maximized
        h header_minimize
      else
        h header_maximize, {id}
      h header_close, {id}
    ]

  header_name = ({children}) ->
    className = style ->
      display: 'block'
      fontSize: '1.5em'
      marginBottom: '.2em'
    h 'name', {className, children}

  header_active = ({active}) ->
    className = style ->
      display: 'block'
      fontSize: '.8em'
      color: 'rgba(0,0,0,.5)'
    h 'active', {className}, [
      relativeTime active
    ]

  header_button = ({icon, left, right, onClick}) ->
    className = style ->
      {
        position: 'absolute'
        display: 'flex'
        width: '5rem'
        height: '9rem'
        cursor: 'pointer'
        color: 'rgba(0,0,0,.5)'
        alignItems: 'center'
        justifyContent: 'center'
        zIndex: -1
        top: 0
        left
        right
      }
    h 'a.material-icons',
      {className, onClick},
      icon

  header_minimize = ->
    icon = 'flip_to_back'
    left = 0
    onClick = ->
      dispatch type: 'minimize'
    h header_button, {icon, left, onClick}

  header_maximize = ({id}) ->
    icon = 'launch'
    left = 0
    onClick = ->
      dispatch {type: 'maximize', id}
    h header_button, {icon, left, onClick}

  header_close = ({id}) ->
    icon = 'close'
    right = 0
    onClick = ->
      dispatch {type: 'close', id}
    h header_button, {icon, right, onClick}

  messages = ({messages}) ->
    className = style ->
      position: 'absolute'
      top: 0
      left: 0
      right: 0
      bottom: '9rem'
      overflow: 'auto'
      padding: '2em'
      paddingTop: '8em'
      boxSizing: 'border-box'
      '-webkitOverflowScrolling': 'touch'
    h 'messages', {className}, [
      for data in messages
        h message, data
    ]

  message = (data) ->
    {me} = data
    className = style ->
      display: 'block'
      textAlign: 'right' if me
      boxSizing: 'border-box'
      clear: 'both'
    h 'message', {className}, [
      h message_text, data
    ]

  message_text = ({me, text}) ->
    className = style ->
      display: 'block'
      padding: '.5em'
      color: if me then 'white' else 'black'
      background: if me then '#2196F3' else '#eee'
      maxWidth: '50%'
      borderRadius: '1em'
      marginBottom: '1em'
      float: if me then 'right' else 'left'
      boxShadow: '0 .2em 1em rgba(0,0,0,.05)'
    h 'text', {className}, text

  form = ->
    onSubmit = prevent
    className = style ->
      position: 'absolute'
      bottom: 0
      left: 0
      right: 0
      height: '9rem'
      boxSizing: 'border-box'
      boxShadow: '0 -.5em 2em rgba(0,0,0,.1)'
    h 'form', {className, onSubmit}, [
      h form_input
    ]

  form_input = ->
    className = style ->
      width: '100%'
      border: 'none'
      padding: '1.4em'
      paddingRight: '8em'
      outline: 'none'
      fontSize: '1.5em'
      fontWeight: 100
      boxSizing: 'border-box'
    h 'input', {
      className
      type: 'text'
      placeholder: 'Type a message...'
    }

  sidebar = ->
    className = style ->
      position: 'fixed'
      top: 0
      left: 0
      bottom: 0
      width: '30rem'
      background: 'white'
      overflow: 'auto'
      boxShadow: '0 .7em 2em rgba(0,0,0,.2)'
      '-webkitOverflowScrolling': 'touch'
    h 'sidebar', {className}, [
      for user in users
        h item, user
    ]

  item = ({id, image, name, message, time}) ->
    onClick = ->
      dispatch {type: 'open', id}
    className = style ->
      display: 'block'
      clear: 'both'
      padding: '1em'
      cursor: 'pointer'
      overflow: 'hidden'
      boxShadow: '0 .7em 2em rgba(0,0,0,.05)'
      boxSizing: 'border-box'
      transition: 'background 200ms'
      '&:hover':
        background: '#2196F3'
        boxShadow: '0 .7em 2em rgba(0,0,0,.2)'
    h 'item', {onClick, className}, [
      h item_image, {image}
      h item_name, {name}
      h item_message, {message}
      # h item_time, {time}
    ]

  item_image = ({image}) ->
    src = image
    className = style ->
      width: '3em'
      height: '3em'
      float: 'left'
      marginRight: '1em'
      borderRadius: '100%'
    h 'img', {src, className}

  item_name = ({name}) ->
    className = style ->
      display: 'block'
      fontWeight: 500
      margin: '.25em 0'
    h 'name', {className}, name

  item_message = ({message}) ->
    className = style ->
      display: 'block'
      color: 'rgba(0,0,0,.5)'
      fontSize: '.9em'
      whiteSpace: 'nowrap'
      overflow: 'hidden'
      textOverflow: 'ellipsis'
    h 'message', {className}, message

  item_time = ({time}) ->
    h 'time', relativeTime time

  # redux

  reducers =
    maximized: (state=true, {type}) ->
      switch type
        when 'maximize' then true
        when 'minimize' then false
        else state
    chats: (state=[], {type, id}) ->
      switch type
        when 'open', 'maximize'
          user = users[id]
          array = remove user, state
          [user, array...]
        when 'close'
          user = users[id]
          remove user, state
        else state
  {createStore, combineReducers} =
    require 'redux'
  {getState,dispatch,subscribe} =
    createStore combineReducers reducers

  # rendering

  subscribe ->
    console.log getState()

  update = ->
    {render} = require 'inferno'
    view = h messenger, getState()
    render view, dom
  subscribe update
  update()
