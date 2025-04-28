//
//  User.swift
//  scava
//
//  Created by Odin Lindal on 4/26/25.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    let devUser: Bool
    
    //ADD SOME PHOTO FUNCTIONALITY HERE
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}

extension User {
    static var MOCK_USER = User(id: NSUUID().uuidString, fullname: "Richard Hendricks",
                                email: "rhendricks@piedpiper.com", devUser: true)
}
