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
    messaging:
      provider: rabbitmq
    persistence:
      provider: postgres
      endpoint: "${orders_db_endpoint}"
      secret:
        create: true
        username: ordersadmin
        password: "${orders_db_password}"
  resources:
    requests:
      cpu: 10m
      memory: 64Mi
  rabbitmq:
    create: true

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
  app:
    persistence:
      provider: redis
  resources:
    requests:
      cpu: 10m
      memory: 64Mi
  redis:
    create: true

ui:
  service:
    type: LoadBalancer
  resources:
    requests:
      cpu: 10m
      memory: 64Mi