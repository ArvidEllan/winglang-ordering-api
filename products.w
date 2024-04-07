bring cloud;
bring ex;
bring util;
bring http;

enum ColumnType {
  STRING,
  NUMBER
}

/*************************************************************************
 * Define a product Item Struct
 *************************************************************************/

 struct Product {
    id: str;
    name: str;
    qty: num;
    price: num;
    imageUrl: str;
  }

  /*************************************************************************
 * Define product interface
 *************************************************************************/
pub interface IProductStorage extends std.IResource {
    inflight add(product: Json): str;
    inflight remove(id: str): void;
    inflight get(id: str): Product?;
    inflight updateProduct(id: str, qty: num): void;
    inflight list(): Array<Json>;
  }
