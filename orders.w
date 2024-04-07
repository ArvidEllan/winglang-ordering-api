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