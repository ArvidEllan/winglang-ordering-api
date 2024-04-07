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
