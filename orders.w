bring cloud;
bring ex;
bring util;
bring http;
bring expect;
bring "./products.w" as product;
// let queue = new cloud.Queue();

enum ColumnType {
  STRING,
  NUMBER
}

enum OrderStatus {
  PENDING,
  PROCESSING,
  COMPLETED
}

/*************************************************************************
 * Define an order Item Struct
 *************************************************************************/
struct Order {
  id: str;
  productId: str;
  qty: num;
  status: str;
}
/*************************************************************************
 * Define Order interface
 *************************************************************************/
interface IOrderStorage extends std.IResource {
  inflight add(id: str, j: Json): void;
  inflight get(id: str): Order?;
  inflight list(): Array<Json>?;
  inflight updateOrderStatus(id: str, status: str): void;
}


/******************************************************************************
 * Create a OrderStorage Class that implements the IOrderStorage interface
 *****************************************************************************/
 pub class OrderStorage impl IOrderStorage {
  db: ex.Table;
  counter: cloud.Counter;
  new() {
    let orderProps = ex.TableProps{
      name: "OrdersTable",
      primaryKey: "id",
      columns: {
        id: ColumnType.STRING,
        prodId: ColumnType.STRING,
        qty: ColumnType.NUMBER,
        status: ColumnType.STRING
      }
    };
    this.db = new ex.Table(orderProps);
    this.counter = new cloud.Counter();
  }

  pub inflight add(name: str, productData: Json) {
    let id = "{this.counter.inc()}";
    this.db.insert(id, productData);
    
  }

  pub inflight remove(id: str) {
    this.db.delete(id);
    log("deleting product {id}");
  }

  pub inflight get(id: str): Order {
  let orderJson = this.db.tryGet(id);
      return Order.fromJson(orderJson);
  }

  pub inflight list(): Array<Json> {
  let orderJson = this.db.list();
      return orderJson;
  }

  pub inflight updateOrderStatus(id: str, status: str) {
      let updatedItem = {
        status: status
      };
      this.db.update(id, updatedItem);
    }
}
/***************************************************
 * Create a OrderService Class with api endpoints
 ***************************************************/
pub class OrderService {
  pub api: cloud.Api;
  storage: IOrderStorage;
  prodStorage: product.IProductStorage;
  counter: cloud.Counter;
  queue: cloud.Queue;
  
  
  new(storage: IOrderStorage, prodStore: product.IProductStorage, queue: cloud.Queue) {
    this.api = new cloud.Api({
      cors: true,
      corsOptions: {
        allowHeaders: ["*"],
        allowMethods: [http.HttpMethod.POST],
      },
    }) as "orders api";

    this.storage = storage;
    this.prodStorage = prodStore;
    this.counter = new cloud.Counter();
    this.queue = queue;

    // API endpoints
    this.api.post("/order/:id/:qty", inflight (req): cloud.ApiResponse => {
      if let body = req.body {
        let id = "{this.counter.inc()}";
        let prodId = req.vars.get("id");
        let orderQty = req.vars.get("qty");
        this.storage.add(id, {id: id, qty: num.fromStr(orderQty), prodId: prodId, status: "PENDING"});
        log("Sending to queue");
        queue.push(Json.stringify({
                id: id,
                prodId: prodId,
                orderQty: orderQty
              }));
              log("Queue recieved");
        return {
          status:201,
          body: prodId
        };
      } else {
        return {
          status: 400,
        };
      }
    });

    this.api.get("/order/:id", inflight (req): cloud.ApiResponse => {
        let id = req.vars.get("id");
        let order = this.storage.get(id);
        return {
          status:200,
          body: Json.stringify(order)
        };
    });

    this.api.get("/orders", inflight (req): cloud.ApiResponse => {
        let order = this.storage.list();
        return {
          status:200,
          body: Json.stringify(order)
        };
    });
/***************************************************
 * Setup a queue consumer
 ***************************************************/
    this.queue.setConsumer(inflight (message) => {
      let orderInfo = Json.parse(message);
      let id = orderInfo.get("id").asStr();
      let prodId = orderInfo.get("prodId").asStr();
      let orderQty = orderInfo.get("orderQty").asStr();
      this.prodStorage.updateProduct(prodId, num.fromStr(orderQty));
      this.storage.updateOrderStatus(id, "COMPLETED");
    }, timeout: 3s);
    
  }
}
