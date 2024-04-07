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

