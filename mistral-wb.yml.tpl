---
version: "2.0"

name: ${name}

workflows:
  unshelve:
    tasks:
      start_server:
        action: nova.servers_unshelve
        input:
          action_region: "${region}"
          server: "${id}"

  shelve:
    tasks:
      stop_server:
        action: nova.servers_shelve
        input:
          action_region: "${region}"
          server: "${id}"

