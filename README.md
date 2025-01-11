# MT Printers
Simple FiveM printers script

# Preview
https://youtu.be/IqUXADVi6n8

# Features
- Printers items
- Place the printer wherever you like
- Save locations even after server restart
- Print any kind of image
- Items based on the document image and label
- Little UI to check the document image
- Need of paper to print the documents

# Requirements
- ox_lib
- ox_target
- ox_inventory

# Installation
- Add this items for your ox_inventory
```lua
["low_printer"] = {
  label = "Small printer",
  weight = 500,
  stack = true,
  close = true,
  client = {
    export = 'mt_printers.usePrinter'
  }
},
["print_document"] = {
  label = "Printed document",
  weight = 0,
  stack = true,
  close = true,
  client = {
    export = 'mt_printers.useDocument'
  }
},
["printer_paper"] = {
  label = "Blank paper",
  weight = 0,
  stack = true,
  close = true,
},
```
- Add the items image for your inventory <br>
- Run the sql.sql file on your server database <br>
- On the ox_inventory/modules/utils/server.lua add:
```lua
['i.ibb.co'] = true
```
to the validHosts
