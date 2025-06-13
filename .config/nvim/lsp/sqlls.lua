return {
    cmd = { "sql-language-server", "up", "--method", "stdio" },
    filetypes = { "sql", "mysql" },
    settings = {
        sql = {
            connections = {
                {
                    driver = "mysql",
                    name = "test-Driver",
                    database = "testDB",
                    username = "root",
                    password = "Anas#1234",
                    host = "localhost",
                    port = 3306
                },
            }
        }
    },
    init_options = {
        provideFormatter = true,
    }
}
