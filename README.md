# SimpleMySQLClassGenerator
This is simple command line program to generate data class for MySQL Table using novi/mysql-swift

This app can generate set of swift classes match with your own MySQL tables. Those classes let you connect and get data from MySQL easily and swifty way. No need to use dictionary to access properties.

# Install (OSX)

Set up your swift project to be able to use [novi/mysql-swift: A type safe MySQL client for Swift] (https://github.com/novi/mysql-swift)
This requires you to Install
- swiftenv 
- mysqlclient
- Xcode 7.3 or above
- Swift 3.0 Snapshot 05-09
 
### Download or clone this project

This repository has nice make file set up, so you can easily create xcode project.

``` 
$ make xcode 
```

This sould make you xcode project you can open.

# Edit for your setting

Edit Settings.swift for matching your setting. 
- MySQL HOST
- MYSQL User / pass
- Database name
- encoding
- TimeZone
- Sources Output Folder 
(If you run this program from command line, you can use relative path like `./Output/Sources` or `~/Desktop`)
(This program does not create folder so please create before run.)

# Run program to generage classes

You can run program from either xcode or commandline.

```
$ make run
```

# copy generated program to your swift Sources Folder
Copy files to your own program to access mysql, of course, you can pick only one you need to use.

# Access MySQL
```Package.swift
import PackageDescription
let package = Package(
    name: "hello",
    dependencies: [
                      .Package(url: "https://github.com/tomohisa/mysql-swift.git", majorVersion: 0, minor: 2),
                      ]
)
```

change this below to your setting again.
```main.swift
// Change below parameters to match your Environment
struct Constants: ConnectionOption {
    var host: String = "127.0.0.1"
    var port: Int = 3306
    var user: String = "root"
    var password: String = "CHANGE_TO_YOUR_PASSWORD"
    var database: String = "CHANGE_TO_YOUR_PASSWORD"
    var encoding: MySQL.Connection.Encoding = .UTF8MB4
    var timeZone: MySQL.Connection.TimeZone = MySQL.Connection.TimeZone(GMTOffset: 60 * 60 * 9) // JST

}

do {
    let constants = Constants()
    let pool = ConnectionPool(options: constants)
    try pool.execute { conn in
        let tables : [TableList] = try conn.query("select * from tblList")
        print(tables)
    }
    print("successfully finished")
} catch let error {
    print("error\(error)")
}
```

For more info, you can check on original swift repository.
[novi/mysql-swift: A type safe MySQL client for Swift] (https://github.com/novi/mysql-swift)
