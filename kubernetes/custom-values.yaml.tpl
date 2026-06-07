catalog:
  app:
    persistence:
      provider: mysql
      endpoint: "${catalog_db_endpoint}"
      secret:
        create: true
        username: catalogadmin
        password: "${catalog_db_password}"
  resources:
    requests:
      cpu: 10m
      memory: 64Mi

orders:
  app:
    persistence:
      provider: postgresql
      endpoint: "${orders_db_endpoint}"
      secret:
        create: true
        username: ordersadmin
        password: "${orders_db_password}"
  resources:
    requests:
      cpu: 10m
      memory: 64Mi

cart:
  app:
    persistence:
      provider: dynamodb
      dynamodb:
        tableName: "${carts_table_name}"
        createTable: false
  resources:
    requests:
      cpu: 10m
      memory: 64Mi

checkout:
  resources:
    requests:
      cpu: 10m
      memory: 64Mi

ui:
  service:
    type: LoadBalancer
  resources:
    requests:
      cpu: 10m
      memory: 64Mi