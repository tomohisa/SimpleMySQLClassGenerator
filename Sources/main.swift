import MySQL
import Environment
import File
import POSIXRegex
import String
import Foundation

print("Welcome!")

struct MySQLDescription: QueryRowResultType, QueryParameterDictionaryType  {
    var field: String?
    var type: String?
    var null: String?
    var key_: String?
    var default_: String?
    var extra: String?
    func swiftType() throws -> String {
        guard
            let type = self.type
            else { return "" }
        var swiftType = ""
        if try Regex(pattern: "(int|year)", options: Regex.RegexOptions(rawValue:3)).matches(type) { swiftType = "Int" }
        if try Regex(pattern: "(text|varchar|char)", options: Regex.RegexOptions(rawValue:3)).matches(type) { swiftType = "String" }
        if try Regex(pattern: "(date|time)", options: Regex.RegexOptions(rawValue:3)).matches(type) { swiftType = "SQLDate" }
        if try Regex(pattern: "(decimal|double|float)", options: Regex.RegexOptions(rawValue:3)).matches(type) { swiftType = "Double" }
        if self.null == "YES" { swiftType += "?" }
        return swiftType
    }
    func isAutoIncrement() -> Bool {
        guard
            let extra = self.extra
            else { return false }
        do {
            return try Regex(pattern: "(auto_increment)", options: Regex.RegexOptions(rawValue:3)).matches(extra)
        } catch { return false }
    }
    func swiftFieldName() -> String {
        guard var field = self.field else { return ""}
        field = field.replacingOccurrences(of: "#", with: "")
        return field
    }
    func dbFieldName() -> String {
        guard var field = self.field else { return ""}
        field = field.replacingOccurrences(of: "#", with: "")
        return field
    }
    func nullchar() throws -> String {
        var type = ""
        if self.null == "YES" { type += "?" }
        return type
    }
    // Decode query results (selecting rows) to the model
    // see selecting sample
    static func decodeRow(r: QueryRowResult) throws -> MySQLDescription {
        return try MySQLDescription(
            field: r <|? "Field",
            type: r <|? "Type",
            null: r <|? "Null",
            key_: r <|? "Key",
            default_: r <|? "Default",
            extra: r <|? "Extra"
        )
    }
    
    // Use the model as a query paramter
    // see inserting sample
    func queryParameter() throws -> QueryDictionary {
        return QueryDictionary(
            ["Field": field
                ,"Type": type
                ,"Null": null
                ,"Key": key_
                ,"Default": default_
                ,"Extra": extra
            ])
    }
}

struct TableList: QueryRowResultType {
    let tableName: String
    static func decodeRow(r: QueryRowResult) throws -> TableList {
        return try TableList(
            tableName: r <| 0
        )
    }
}

struct TableInfo {
    var tableName = ""
    var className = ""
}

do {
    let constants = Constants()
    let pool = ConnectionPool(options: constants)
    try pool.execute { conn in
        let tables : [TableList] = try conn.query("SHOW TABLES FROM \(constants.database)")
        for table in tables {
            
            var info = TableInfo()
            info.tableName = table.tableName
            
            info.className = convertTableNameFrom(tableName: table.tableName)
            
            let sql = "Desc \(info.tableName);"
            let columns : [MySQLDescription] = try conn.query(sql)
            
            let path = "\(constants.outputFolder)/\(info.className).swift"
            let file = try File(path: path, mode: .truncateReadWrite)
            
            print("exporting swift file for \(info.tableName) ... \(path)")
            
            var source = ""
            source += "import MySQL\n\n"
            source += "public struct \(info.className): QueryRowResultType, QueryParameterDictionaryType {\n"
            for column in columns {
                source += "    public var \(column.swiftFieldName()): \(try column.swiftType())\n"
            }
            source += "    public static func decodeRow(r: QueryRowResult) throws -> \(info.className) {\n"
            source += "        return try \(info.className)(\n"
            var comma = ""
            for column in columns {
                source += "            \(comma)\(column.swiftFieldName()): r <|\(try column.nullchar()) \"\(column.dbFieldName())\"\n"
                comma = ","
            }
            source += "        )\n"
            source += "    }\n"
            source += "    public func queryParameter() throws -> QueryDictionary {\n"
            source += "        return QueryDictionary([\n"
            for column in columns {
                if column.isAutoIncrement() { continue }
                source += "            \"\(column.swiftFieldName())\": \(column.dbFieldName()),\n"
            }
            source += "        ])\n"
            source += "    }\n"
            source += "}\n"
            try file.write(source.data)
            try file.close()
        }
    }
    print("successfully finished")
} catch let error {
    print("error\(error)")
}




