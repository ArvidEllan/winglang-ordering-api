bring cloud;
bring ex;
bring util;
bring http;
bring expect;
bring "./products.w" as product;
bring "./orders.w" as order;
let queue = new cloud.Queue();


/***************************************************
 * Instantiating the instance of the defined classes.
 ***************************************************/
let productStorage = new product.ProductStorage();
let orderStorage = new order.OrderStorage();
let productApi = new product.ProductService(productStorage);
let orderApi = new order.OrderService(orderStorage, productStorage, queue);
