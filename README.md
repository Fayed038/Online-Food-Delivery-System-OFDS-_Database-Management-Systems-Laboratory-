# Online Food Delivery System

## Overview
This project is a database design for an Online Food Delivery System, created as part of a team project by:

**Contributors:**  
- Md Hammad Ullah Fayed  
- Ahmad Shawqi

## Database Schema

See the ERD below for relationships:

![ERD](erd.png)

### Tables
- **users**: Stores customer information.
- **restaurants**: Stores info about partner restaurants.
- **menu_items**: Menu items offered by restaurants.
- **orders**: Customer orders.
- **order_items**: Items within each order.
- **delivery_persons**: Info about delivery staff.
- **payments**: Records of payments made.

## Usage

1. Run `schema.sql` to create tables.
2. Run `queries.sql` to add sample data or execute example queries.

## Setup

```bash
psql -U youruser -d yourdb -f schema.sql
psql -U youruser -d yourdb -f queries.sql
```

## License

MIT
