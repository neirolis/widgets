# RTMIP widgets

Widgets are information elements located on the "dashboard" page. A plugin widget is a single file located in the `widgets` directory of RTMIP.

It can be:

1. `html`(.html) file, with embedded javascript and css rules, if it required.
2. `markdown`(.md) code that will bec onverted to html during initialization.
3. `template`(.tmpl) in [go tamplates](https://pkg.go.dev/html/template) format, which is executed and converted to html.
4. or an `executable` file that will return html code as a result.

Text, non executable, widgets, like `html`, `markdown` or `template`, they are rendered only once when the dashboard page is opened by the user. While for executable widgets, they are launched each time according to the specified interval.

It is important to keep in mind that you cannot use `const` and `let` in javascript code to declare variables, this causes errors when redrawing the page by **React**. All variables must be declared via `var`.

## Widgets functions

From the context of widgets, as well as custom pages, some global functions and objects are available.

### Popup:

`alert(string|Error)` - display alert message as popup alert instead browser window.

`success(string|undefined)` - display popup success message.

### Localization:

`i18n.lang() -> string` - returns current language.

`i18n.t(key:string) -> string` - translate some key by translate dictionary, ie: `i18n.t('apply')` - will be displayed as "Apply"/"Aplicar"/"Применить" according current language.

`i18n.exists(key:string) -> boolean` - returns true if this localization key exists in the translate dictionary.

### RTMIP API access:

Widgets has access to the `RTMIP` object provide client to the backend API, it does not require additional authorization or anything else. All functions correspond to the API described in swagger. You can see the full list of available functions using console messages: `console.log(RTMIP)`

`RTMIP.url(path:string) -> string` - returns the URL, up to the RTMIP backend, in most cases it prepend "/" to the start of path, but if the frontend is hosted by other services, for example nginx, then this function will add the ip address, and port if it differs from the defaults.

`RTMIP.urlauth(path:string) -> string` - same as `RTMIP.url(path)` but substitute `jwt` token to the query variables.

`RTMIP.GET(path:string, data?:any)` - GET request by specified path to the `/api`, for exampke: `RTMIP.GET("/user")` - returns current user, do not required to prepand `/api`.

`RTMIP.POST(path:string, data?:any)` - POST request

`RTMIP.DELETE(path:string)` - DELETE request

`RTMIP.FILE(path:string, name:string, file:Blob, filename?:string)` - upload file to the backend

## Examples

### Time

An example of a widget that will draw the current time on the server:

```bash
#!/bin/bash
time=$( date +"%H : %M : %S" )
echo "<h3>$time</h3>"
```

With an interval of 1 second, the widget will be redrawn every second.

### IP address

Widget returns current white ip address:

```bash
#!/bin/bash
ip=$(curl -s ipinfo.io/ip)
echo "<h3>$ip</h3>"
```

In this case, it is recommended to set a larger interval.

### Select color

HTML widget with javascript, stylized to match the rest of the UI, with the state saved on the backend.

```html
<div
  id="wgtcolors"
  class="rs-dropdown rs-dropdown-placement-bottom-start"
  role="menu"
  style="width: 100%;"
>
  <ul
    class="rs-dropdown-menu"
    role="menu"
    style="width: 100%; display: none; margin-top: 36px;"
  >
    <li class="rs-dropdown-item" onclick="_wgtcolors.set('red')">
      <a class="rs-dropdown-item-content">red</a>
    </li>
    <li class="rs-dropdown-item" onclick="_wgtcolors.set('blue')">
      <a class="rs-dropdown-item-content">blue</a>
    </li>
    <li class="rs-dropdown-item" onclick="_wgtcolors.set('yellow')">
      <a class="rs-dropdown-item-content">yellow</a>
    </li>
    <li class="rs-dropdown-item" onclick="_wgtcolors.set('green')">
      <a class="rs-dropdown-item-content">green</a>
    </li>
  </ul>
  <a
    tabindex="0"
    class="rs-btn rs-btn-subtle rs-dropdown-toggle"
    onclick="_wgtcolors.open()"
    style="width: 100%;"
    >...</a
  >
</div>

<script defer>
  var wgt = document.getElementById('wgtcolors')
  var wgt_id = wgt.parentNode.id

  var menu = wgt.querySelector('ul')
  var value = wgt.querySelector('a.rs-dropdown-toggle')

  var _wgtcolors = {
    open: () => {
      menu.style.display = menu.style.display == 'none' ? 'block' : 'none'
    },

    set: (color) => {
      value.innerHTML = color
      RTMIP.setWidget(wgt_id, { color: color })
        .then(console.log)
        .catch(console.error)
      menu.style.display = 'none'
    },

    load: () => {
      RTMIP.dashboard().then((dashboard) => {
        const w = dashboard.widgets.find((wgt) => wgt.id == wgt_id)
        if (w.handlerData) value.innerHTML = w.handlerData.color[0]
      })
    },
  }

  _wgtcolors.load()
</script>
```
