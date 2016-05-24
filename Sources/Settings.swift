//
//  Settings.swift
//  SimpleMySQLClassGenerator
//
//  Created by Tomohisa Takaoka on 5/24/16.
//
//
import MySQL
import Environment
import File
import POSIXRegex
import String
import Foundation


// Change below parameters to match your envirionment
struct Constants: ConnectionOption {
    var host: String = "127.0.0.1"
    var port: Int = 3306
    var user: String = "root"
    var password: String = "CHANGE_TO_YOUR_PASSWORD"
    var database: String = "CHANGE_TO_YOUR_DB_NAME"
    var encoding: MySQL.Connection.Encoding = .UTF8MB4
    var timeZone: MySQL.Connection.TimeZone = MySQL.Connection.TimeZone(GMTOffset: 60 * 60 * 9) // JST

    // WHEN YOU USE XCODE, you can NOT use relative path
    var outputFolder : String = "/Users/tomohisa/Desktop/Output/Sources"
}

// REWRITE Conversion of Table name to Class Name
// currently:
//      myDBName -> TableMyDBName
//      tblCountry -> TableCountly
func convertTableNameFrom(tableName:String) -> String {
    var className = "Table" + tableName.substring(to: tableName.index(tableName.startIndex, offsetBy: 1)).uppercased() + tableName.substring(from: tableName.index(tableName.startIndex, offsetBy: 1))
    className = className.replacingOccurrences(of: "Tbl", with: "")
    return className
}
