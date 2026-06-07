catalog:
  app:
    persistence:
      provider: mysql
      endpoint: "${catalog_db_endpoint}"
      secret:
        create: true
        username: catalogadmin
        password: "${catalog_db_password}"

orders:
  app:
    persistence:
      provider: postgresql
      endpoint: "${orders_db_endpoint}"
      secret:
        create: true
        username: ordersadmin
        password: "${orders_db_password}"

cart:
  app:
    persistence:
      provider: dynamodb
      dynamodb:
        tableName: "${carts_table_name}"
        createTable: false
