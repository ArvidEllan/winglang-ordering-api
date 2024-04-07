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
