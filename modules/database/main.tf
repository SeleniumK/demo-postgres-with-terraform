// Defaults to being owned by the user associated with the provider
resource "postgresql_schema" "pgcon" {
  name  = "pgcon"
  drop_cascade = true
}

resource "postgresql_role" "pgcon_application_user" {
  name     = "pgcon_application_user"
  password = var.pgcon_application_password
  login    = true
  roles = ["pg_read_all_data", "pg_write_all_data"]
  search_path = [postgresql_schema.pgcon.name]
}

resource "postgresql_role" "pgcon_readonly_user" {
  name     = "pgcon_readonly_user"
  password = var.pgcon_readonly_password
  login    = true
  search_path = [postgresql_schema.pgcon.name]
}

resource "postgresql_role" "pgcon_limited_user" {
  name     = "pgcon_limited_user"
  password = var.pgcon_limited_password
  login    = true
  search_path = [postgresql_schema.pgcon.name]
}


// read only from the pgcon schema for the readonly user
resource "postgresql_grant" "readonly_database" {
  role        = postgresql_role.pgcon_readonly_user.name
  database    = var.database_name
  object_type = "database"
  privileges  = ["CONNECT"]
}

resource "postgresql_grant" "readonly_schema" {
  role        = postgresql_role.pgcon_readonly_user.name
  database    = var.database_name
  schema      = postgresql_schema.pgcon.name
  object_type = "schema"
  privileges  = ["USAGE"]
}

data "postgresql_tables" "all_pgcon_tables" {
  database    = var.database_name
  schemas      = [postgresql_schema.pgcon.name]
}

resource "postgresql_grant" "readonly_tables" {
  role        = postgresql_role.pgcon_readonly_user.name
  database    = var.database_name
  schema      = postgresql_schema.pgcon.name
  object_type = "table"
  objects = [
    for x in data.postgresql_tables.all_pgcon_tables.tables: x.object_name
  ]
  privileges  = ["SELECT"]
}

resource "postgresql_grant" "limited_database" {
  role        = postgresql_role.pgcon_limited_user.name
  database    = var.database_name
  object_type = "database"
  privileges  = ["CONNECT"]
}

resource "postgresql_grant" "limited_schema" {
  database    = var.database_name
  role        = postgresql_role.pgcon_limited_user.name
  schema      = postgresql_schema.pgcon.name
  object_type = "schema"
  privileges  = ["USAGE"]
}

// Read only tables from the pgcon schema 
//that do not contain the word 'secret' in them
data "postgresql_tables" "non_secret_pgcon_tables" {
  database    = var.database_name
  schemas      = [postgresql_schema.pgcon.name]
  not_like_all_patterns = ["%%secret%%"]
}


resource "postgresql_grant" "limited_tables" {
  role        = postgresql_role.pgcon_limited_user.name
  database    = var.database_name
  schema      = postgresql_schema.pgcon.name
  object_type = "table"
  objects = [
    for x in data.postgresql_tables.non_secret_pgcon_tables.tables: x.object_name
  ]
  privileges  = ["SELECT"]
}


resource "postgresql_extension" "postgis" {
  name = "postgis"
  schema = postgresql_schema.pgcon.name
}

resource "postgresql_function" "add_eight" {
    name = "special_add_eight"
    schema      = postgresql_schema.pgcon.name
    arg {
        name = "i"
        type = "integer"
    }
    returns = "integer"
    language = "plpgsql"
    body = <<-EOF
        BEGIN
          RETURN i + 8;
        END;
    EOF
}

