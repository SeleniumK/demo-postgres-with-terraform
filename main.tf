// Set up a provider talking to your instance -- In this case, localhost
provider "postgresql" {
  alias           = "pgcon2024_instance"
  host            = "localhost"
  port            = 5432
  database        = "postgres"
  username        = "postgres"
// We aren't going to configure ssl, timeouts, or client certs -- But you can!
  sslmode         = "disable"
#   connect_timeout = 15
#   clientcert {
#     cert = "/path/to/public-certificate.pem"
#     key  = "/path/to/private-key.pem"
#   }
}

resource "postgresql_database" "pgcon" {
  provider = postgresql.pgcon2024_instance
  name     = "pgcon"
}

resource "postgresql_role" "pgcon_superuser" {
  provider = postgresql.pgcon2024_instance
  name     = "pgcon_superuser"
  password = var.pgcon_superuser_password
  superuser = true
  login    = true
  create_role = true
  search_path = [postgresql_database.pgcon.name]
}

// This provider specifies our new database with our new user!
// -- Not strictly necessary, but limits
// what tf can talk to & allows us to be certain that everything using this provider is
// acting on the same database
provider "postgresql" {
  alias           = "pgcon2024_database"
  host            = "localhost"
  port            = 5432
  database        = postgresql_database.pgcon.name
  username        = postgresql_role.pgcon_superuser.name
  password        = var.pgcon_superuser_password
  sslmode         = "disable"
}


// Run database level operations using the db specific
module "database" {
  source = "./modules/database"
  providers = {
    postgresql = postgresql.pgcon2024_database
  }
  database_name = postgresql_database.pgcon.name
  pgcon_application_password = var.pgcon_application_password
  pgcon_readonly_password = var.pgcon_readonly_password
  pgcon_limited_password = var.pgcon_limited_password
}
