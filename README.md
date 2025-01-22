# E-commerce API

This project is designed as an e-commerce API, allowing users to view products, create carts, and place orders.

## Ruby Version

- Ruby 2.7.8

## System Dependencies

- Rails 6.1.7
- PostgreSQL
- Sidekiq
- Docker and Docker Compose

## Installation

### 1. Clone the Project

```bash
git clone https://github.com/baranyeni/ecommerce-api
cd ecommerce-api
```

### 2. Build the Docker Image

```bash
docker-compose up --build
```

### 3. Create the database and fill it with seed data

```bash
 docker-compose run web rails db:setup
```

## API Usage Examples (cURL)

### Customer
#### Create a new customer:
```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "mutation { createCustomer(firstName: \"John\", lastName: \"Doe\", email: \"john.doe@example.com\", phoneNumber: \"1234567890\") { customer { id firstName lastName email phoneNumber } } }"}'

```

#### Fetch a customer by ID:
```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "query { customer(id: 1) { id firstName lastName email phoneNumber } }"}'
```

#### Fetch customer's cart items:
```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "query { customer(id: 1) { id firstName lastName cartItems { id quantity product { name description price } } } }"}'
```

#### Fetch customer's ongoing orders:
```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "query { customer(id: 1) { id firstName lastName ongoingOrders { id  orderItems { id quantity product {name description price} } } } }"}'
```

### Product
#### Fetch all products:
```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "query { products { id name description price stockCount } }"}'
```

#### Fetch a product by ID:
```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "query { product(id: 1) { id name description price stockCount } }"}'
```

### Cart
#### Add a product to a cart:
```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "mutation { addToCart(customerId: 1, productId: 1, quantity: 2) { cart { id customerId products { id name description price stockCount quantity } } } }"}'
```

#### Remove a product from a cart:
Need to put quantity to 0


### Order
#### Create an order from a cart:
```bash
curl -X POST http://localhost:3000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "mutation { createOrder(customerId: 2, cartId: 2) { order { id customerId orderItems { id quantity product { name description price } } } } }"}'
```


### Mailer function & jobs
I configured the letter_opener gem so if you run the app and make the cURL request locally, the mail will pop-up on your browser. Unfortunately this does not work for Docker environment.

Here you can see it's working there too
![Screenshot 2025-01-22 at 07 36 08](https://github.com/user-attachments/assets/e29ea42a-3471-4168-83ed-f3b22bbc18d5)


## Tests
To run the tests, you can use the following command:

```bash
docker-compose run web rspec spec --format documentation
```